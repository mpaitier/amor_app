// ============================================================================
// RELATIONS : FONCTIONS APPELABLES
// ============================================================================
// Création d'une relation et adhésion par code. Faites côté serveur pour
// garantir qu'un compte n'appartient qu'à une seule relation et qu'un code
// d'invitation reste unique, quelles que soient les règles Firestore.
//
// Documents écrits :
// - users/{uid}            { coupleId, updatedAt }
// - couples/{coupleId}     { members, profiles, inviteCode, createdBy,
//                            createdAt, lastActivityAt }
// - invites/{inviteCode}   { coupleId, createdAt }

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { randomInt } = require("node:crypto");
const {
  generateInviteCode,
  normalizeInviteCode,
  validateProfile,
} = require("./couples_logic");

// --- Nombre d'essais pour tomber sur un code libre. Avec 31^6 codes
// --- possibles, un seul suffit en pratique ---
const MAX_CODE_ATTEMPTS = 5;

function requireUid(request) {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Connexion requise.");
  return uid;
}

function requireProfile(data) {
  const profile = validateProfile(data);
  if (!profile) {
    throw new HttpsError("invalid-argument", "Surnom ou couleur invalide.");
  }
  return profile;
}

// --- Refuse si la personne fait déjà partie d'une relation ---
async function ensureWithoutCouple(tx, userRef) {
  const userDoc = await tx.get(userRef);
  if (userDoc.exists && userDoc.data().coupleId) {
    throw new HttpsError("already-exists", "Ce compte a déjà une relation.");
  }
}

// --- Cherche un code d'invitation libre (lectures seulement) ---
async function findFreeInviteCode(tx, db) {
  for (let attempt = 0; attempt < MAX_CODE_ATTEMPTS; attempt++) {
    const code = generateInviteCode((max) => randomInt(max));
    const inviteDoc = await tx.get(db.collection("invites").doc(code));
    if (!inviteDoc.exists) return code;
  }
  throw new HttpsError("internal", "Impossible de générer un code d'invitation.");
}

// ============================================================================
// CRÉER UNE RELATION
// ============================================================================

exports.createCouple = onCall(async (request) => {
  const uid = requireUid(request);
  const profile = requireProfile(request.data);

  const db = getFirestore();
  const userRef = db.collection("users").doc(uid);
  const coupleRef = db.collection("couples").doc();

  return db.runTransaction(async (tx) => {
    // --- Toutes les lectures avant la première écriture ---
    await ensureWithoutCouple(tx, userRef);
    const inviteCode = await findFreeInviteCode(tx, db);

    tx.set(coupleRef, {
      members: [uid],
      profiles: { [uid]: profile },
      inviteCode,
      createdBy: uid,
      createdAt: FieldValue.serverTimestamp(),
      lastActivityAt: FieldValue.serverTimestamp(),
    });
    tx.set(db.collection("invites").doc(inviteCode), {
      coupleId: coupleRef.id,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      userRef,
      { coupleId: coupleRef.id, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );

    return { coupleId: coupleRef.id, inviteCode };
  });
});

// ============================================================================
// REJOINDRE UNE RELATION
// ============================================================================

exports.joinCouple = onCall(async (request) => {
  const uid = requireUid(request);
  const profile = requireProfile(request.data);
  const code = normalizeInviteCode(request.data && request.data.code);
  if (!code) throw new HttpsError("not-found", "Code d'invitation inconnu.");

  const db = getFirestore();
  const userRef = db.collection("users").doc(uid);
  const inviteRef = db.collection("invites").doc(code);

  return db.runTransaction(async (tx) => {
    const inviteDoc = await tx.get(inviteRef);
    if (!inviteDoc.exists) {
      throw new HttpsError("not-found", "Code d'invitation inconnu.");
    }

    const coupleRef = db.collection("couples").doc(inviteDoc.data().coupleId);
    const coupleDoc = await tx.get(coupleRef);
    if (!coupleDoc.exists) {
      throw new HttpsError("not-found", "Cette relation n'existe plus.");
    }

    // --- Lien ouvert deux fois : rien à refaire ---
    const members = coupleDoc.data().members || [];
    if (members.includes(uid)) return { coupleId: coupleRef.id };

    await ensureWithoutCouple(tx, userRef);

    tx.update(coupleRef, {
      members: FieldValue.arrayUnion(uid),
      [`profiles.${uid}`]: profile,
    });
    tx.set(
      userRef,
      { coupleId: coupleRef.id, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );

    return { coupleId: coupleRef.id };
  });
});
