// ============================================================================
// CYCLE DE VIE D'UNE RELATION
// ============================================================================
// - deleteAccount      : suppression du compte (app et page web). Les
//                        souvenirs restent pour les autres membres ; le
//                        dernier membre emporte toute la relation.
// - requestCoupleEnd   : demande d'arrêt de la relation, notifiée aux autres
// - respondCoupleEnd   : accepter ou refuser. Quand tous les membres ont
//                        accepté, la relation est supprimée.
// - cancelCoupleEnd    : l'auteur de la demande la retire
// - remindCoupleEnd    : rappel le 6e jour aux membres sans réponse
// - cleanupInactiveCouples : avertissements à J-30 et J-7, suppression de la
//                        relation et des comptes après un an sans activité
//
// La demande est rangée dans couples/{coupleId}.endRequest :
// { requestedBy, requestedAt, acceptedBy, declinedBy, reminderSentAt }

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
const { memberNickname } = require("./recipients");
const { sendToUids } = require("./messaging");
const { deleteCoupleCompletely, deleteUserEverywhere } = require("./deletion");
const {
  endRequestProgress,
  membersWithoutAnswer,
  needsEndReminder,
  inactivityAction,
  inactivityQueryCutoffMs,
} = require("./couple_lifecycle_logic");

function requireUid(request) {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Connexion requise.");
  return uid;
}

// --- Relation de la personne, dont elle doit être membre ---
async function requireMembership(db, uid) {
  const userDoc = await db.collection("users").doc(uid).get();
  const coupleId = userDoc.exists ? userDoc.data().coupleId : null;
  if (!coupleId) throw new HttpsError("failed-precondition", "Aucune relation.");
  const coupleRef = db.collection("couples").doc(coupleId);
  return { coupleId, coupleRef };
}

function millisOf(timestamp) {
  return timestamp && typeof timestamp.toMillis === "function" ? timestamp.toMillis() : undefined;
}

// ============================================================================
// SUPPRESSION DU COMPTE
// ============================================================================

exports.deleteAccount = onCall(async (request) => {
  const uid = requireUid(request);
  const db = getFirestore();

  const userDoc = await db.collection("users").doc(uid).get();
  const coupleId = userDoc.exists ? userDoc.data().coupleId : null;

  if (coupleId) {
    const coupleRef = db.collection("couples").doc(coupleId);
    const deleteAll = await db.runTransaction(async (tx) => {
      const coupleDoc = await tx.get(coupleRef);
      if (!coupleDoc.exists) return false;
      const couple = coupleDoc.data();
      const remaining = (couple.members || []).filter((member) => member !== uid);

      // --- Dernier membre : la relation part avec lui ---
      if (remaining.length === 0) return true;

      const update = {
        members: FieldValue.arrayRemove(uid),
        [`profiles.${uid}`]: FieldValue.delete(),
      };
      if (couple.endRequest) {
        update["endRequest.acceptedBy"] = FieldValue.arrayRemove(uid);
        update["endRequest.declinedBy"] = FieldValue.arrayRemove(uid);
      }
      tx.update(coupleRef, update);

      // --- Ceux qui restent avaient peut-être tous accepté l'arrêt ---
      return endRequestProgress({ ...couple, members: remaining }).allAccepted && !!couple.endRequest;
    });

    if (deleteAll) await deleteCoupleCompletely(db, coupleId);
  }

  await deleteUserEverywhere(db, uid);
  return { deleted: true };
});

// ============================================================================
// FIN DE RELATION D'UN COMMUN ACCORD
// ============================================================================

exports.requestCoupleEnd = onCall(async (request) => {
  const uid = requireUid(request);
  const db = getFirestore();
  const { coupleId, coupleRef } = await requireMembership(db, uid);

  const couple = await db.runTransaction(async (tx) => {
    const coupleDoc = await tx.get(coupleRef);
    const data = coupleDoc.data();
    if (data.endRequest) {
      throw new HttpsError("already-exists", "Une demande est déjà en cours.");
    }
    tx.update(coupleRef, {
      endRequest: {
        requestedBy: uid,
        requestedAt: FieldValue.serverTimestamp(),
        acceptedBy: [uid],
        declinedBy: [],
        reminderSentAt: null,
      },
    });
    return data;
  });

  // --- Seul dans la relation : rien à attendre ---
  const others = (couple.members || []).filter((member) => member !== uid);
  if (others.length === 0) {
    await deleteCoupleCompletely(db, coupleId);
    return { deleted: true };
  }

  const who = memberNickname(couple, uid) || "Ton partenaire";
  await sendToUids(db, others, {
    title: "Demande d'arrêt de la relation",
    body: `${who} souhaite arrêter votre relation sur Amor. Ouvre l'app pour répondre.`,
  });
  return { deleted: false };
});

exports.respondCoupleEnd = onCall(async (request) => {
  const uid = requireUid(request);
  const accept = request.data && request.data.accept === true;
  const db = getFirestore();
  const { coupleId, coupleRef } = await requireMembership(db, uid);

  const allAccepted = await db.runTransaction(async (tx) => {
    const coupleDoc = await tx.get(coupleRef);
    const couple = coupleDoc.data();
    const endRequest = couple.endRequest;
    if (!endRequest) throw new HttpsError("failed-precondition", "Aucune demande en cours.");

    const others = (list) => (list || []).filter((member) => member !== uid);
    const acceptedBy = accept ? [...others(endRequest.acceptedBy), uid] : others(endRequest.acceptedBy);
    const declinedBy = accept ? others(endRequest.declinedBy) : [...others(endRequest.declinedBy), uid];

    tx.update(coupleRef, {
      "endRequest.acceptedBy": acceptedBy,
      "endRequest.declinedBy": declinedBy,
    });
    return endRequestProgress({ ...couple, endRequest: { ...endRequest, acceptedBy } }).allAccepted;
  });

  if (allAccepted) {
    await deleteCoupleCompletely(db, coupleId);
    return { deleted: true };
  }
  return { deleted: false };
});

exports.cancelCoupleEnd = onCall(async (request) => {
  const uid = requireUid(request);
  const db = getFirestore();
  const { coupleRef } = await requireMembership(db, uid);

  await db.runTransaction(async (tx) => {
    const coupleDoc = await tx.get(coupleRef);
    const endRequest = coupleDoc.data().endRequest;
    if (!endRequest) return;
    if (endRequest.requestedBy !== uid) {
      throw new HttpsError("permission-denied", "Seul l'auteur de la demande peut l'annuler.");
    }
    tx.update(coupleRef, { endRequest: FieldValue.delete() });
  });
  return { cancelled: true };
});

// --- Rappel du 6e jour aux membres qui n'ont pas répondu ---
exports.remindCoupleEnd = onSchedule(
  { schedule: "every day 10:00", timeZone: "Europe/Paris" },
  async () => {
    const db = getFirestore();
    const now = Date.now();
    const snapshot = await db.collection("couples").where("endRequest.requestedAt", "!=", null).get();

    for (const doc of snapshot.docs) {
      const couple = doc.data();
      const endRequest = couple.endRequest;
      if (!needsEndReminder(endRequest, millisOf(endRequest.requestedAt), now)) continue;

      const who = memberNickname(couple, endRequest.requestedBy) || "Ton partenaire";
      await sendToUids(db, membersWithoutAnswer(couple), {
        title: "Une demande attend ta réponse",
        body: `${who} a demandé d'arrêter votre relation il y a 6 jours. Ouvre Amor pour répondre.`,
      });
      await doc.ref.update({ "endRequest.reminderSentAt": FieldValue.serverTimestamp() });
    }
  }
);

// ============================================================================
// RELATIONS INACTIVES
// ============================================================================

exports.cleanupInactiveCouples = onSchedule(
  { schedule: "every day 03:30", timeZone: "Europe/Paris" },
  async () => {
    const db = getFirestore();
    const now = Date.now();
    const cutoff = Timestamp.fromMillis(inactivityQueryCutoffMs(now));
    const snapshot = await db.collection("couples").where("lastActivityAt", "<=", cutoff).get();

    for (const doc of snapshot.docs) {
      const couple = doc.data();
      const action = inactivityAction(
        millisOf(couple.lastActivityAt),
        now,
        couple.inactivityWarnings || {},
      );
      if (!action) continue;

      if (action === "delete") {
        const members = await deleteCoupleCompletely(db, doc.id);
        for (const uid of members) await deleteUserEverywhere(db, uid);
        continue;
      }

      await sendToUids(db, couple.members || [], {
        title: "Amor vous attend",
        body:
          `Sans nouveau souvenir ni nouvelle date d'ici ${action.daysLeft} jours, ` +
          "votre relation et vos comptes seront supprimés.",
      });
      await doc.ref.update({ [`inactivityWarnings.${action.warn}`]: FieldValue.serverTimestamp() });
    }
  }
);
