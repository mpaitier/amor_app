const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const {
  parisParts,
  parisDay,
  addDays,
  isDue,
  preferencesOf,
  specialDayLines,
  reminderTitle,
} = require("./special_days");
const {
  chunk,
  memberNickname,
  isOtherMembersDevice,
  uniqueUids,
} = require("./recipients");

initializeApp();

// ============================================================================
// RELATIONS (création, adhésion par code)
// ============================================================================

const { createCouple, joinCouple } = require("./couples");
exports.createCouple = createCouple;
exports.joinCouple = joinCouple;

// ============================================================================
// OUTILS COMMUNS
// ============================================================================

// --- Appareils rattachés aux comptes donnés (device_tokens.uid) ---
async function devicesOfUids(db, uids) {
  const devices = [];
  for (const ids of chunk(uids, 30)) {
    const snapshot = await db.collection("device_tokens").where("uid", "in", ids).get();
    for (const doc of snapshot.docs) devices.push({ id: doc.id, ...doc.data() });
  }
  return devices;
}

// --- Date de dernière activité de la relation : sert à supprimer les
// --- relations restées un an sans nouveau souvenir ni nouvelle date ---
async function markCoupleActivity(db, coupleId) {
  try {
    await db.collection("couples").doc(coupleId).update({
      lastActivityAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    // --- Relation supprimée entre-temps : rien à mettre à jour ---
  }
}

// ============================================================================
// NOUVEAU SOUVENIR
// ============================================================================
// Prévient les autres membres de la relation, s'ils ont gardé ce type de
// notification. Les documents copiés par le script de migration (champ
// migratedAt) ne déclenchent rien.

exports.notifyOnNewMemory = onDocumentCreated(
  "couples/{coupleId}/timeline_events/{eventId}",
  async (event) => {
    const eventData = event.data.data();
    if (eventData.migratedAt) return;

    const { coupleId } = event.params;
    const db = getFirestore();
    await markCoupleActivity(db, coupleId);

    const coupleDoc = await db.collection("couples").doc(coupleId).get();
    if (!coupleDoc.exists) return;
    const couple = coupleDoc.data();

    const author = {
      creatorUid: eventData.creatorUid || null,
      creatorDeviceId: eventData.creatorDeviceId || null,
    };
    const devices = await devicesOfUids(db, couple.members || []);
    const tokens = devices
      .filter((device) => isOtherMembersDevice(device, author))
      .filter((device) => {
        const preferences = preferencesOf(device);
        return preferences.enabled && preferences.newMemory;
      })
      .map((device) => device.token)
      .filter((token) => !!token);

    if (tokens.length === 0) return;

    const title = eventData.title || "Nouveau souvenir";
    const who = memberNickname(couple, author.creatorUid);
    const body = who
      ? `${who} vient d'ajouter "${title}"`
      : `Un nouveau souvenir a été ajouté : "${title}"`;

    await getMessaging().sendEachForMulticast({
      notification: {
        title: "Nouveau souvenir ❤️",
        body,
      },
      tokens,
    });
  }
);

// ============================================================================
// NOUVELLE DATE IMPORTANTE
// ============================================================================
// Pas de notification : met seulement à jour l'activité de la relation.

exports.recordImportantDateActivity = onDocumentCreated(
  "couples/{coupleId}/important_dates/{dateId}",
  async (event) => {
    if (event.data.data().migratedAt) return;
    await markCoupleActivity(getFirestore(), event.params.coupleId);
  }
);

// ============================================================================
// JOURS SPÉCIAUX (DATES IMPORTANTES ET ANNIVERSAIRES)
// ============================================================================
// Passe toutes les 5 minutes. Pour chaque appareil dont l'heure du jour J ou
// du rappel tombe dans ce créneau, envoie la liste des jours spéciaux de la
// relation de son compte, selon ses préférences.

// --- Charge les dates importantes et les réglages d'une relation ---
async function loadSpecialDaysData(db, coupleId) {
  const coupleRef = db.collection("couples").doc(coupleId);
  const [datesSnapshot, settingsDoc] = await Promise.all([
    coupleRef.collection("important_dates").get(),
    coupleRef.collection("settings").doc("general").get(),
  ]);

  const importantDates = datesSnapshot.docs
    .map((doc) => doc.data())
    .filter((data) => data.date && typeof data.date.toDate === "function")
    .map((data) => ({ first: parisDay(data.date.toDate()), data }));

  let settings = null;
  const raw = settingsDoc.exists ? settingsDoc.data() : null;
  if (raw && raw.relationshipStart && typeof raw.relationshipStart.toDate === "function") {
    const anniversary = raw.anniversary || {};
    const monthAnniversary = raw.monthAnniversary || {};
    settings = {
      start: parisDay(raw.relationshipStart.toDate()),
      showAnniversary: anniversary.show === true,
      anniversaryEmoji: anniversary.emoji || "💍",
      showMonthAnniversaries: monthAnniversary.show === true,
      monthAnniversaryEmoji: monthAnniversary.emoji || "❤️",
    };
  }

  return { importantDates, settings };
}

// --- Relation de chaque compte, lue dans users/{uid}.coupleId ---
async function coupleIdsByUid(db, uids) {
  const entries = await Promise.all(
    uids.map(async (uid) => {
      const userDoc = await db.collection("users").doc(uid).get();
      return [uid, userDoc.exists ? userDoc.data().coupleId || null : null];
    })
  );
  return new Map(entries);
}

exports.notifySpecialDays = onSchedule(
  { schedule: "every 5 minutes", timeZone: "Europe/Paris" },
  async () => {
    const db = getFirestore();
    const now = parisParts(new Date());
    const today = { y: now.y, m: now.m, d: now.d };
    const nowMinutes = now.hour * 60 + now.minute;

    // --- Appareils rattachés à un compte qui ont quelque chose à recevoir
    // --- dans ce créneau ---
    const devicesSnapshot = await db.collection("device_tokens").get();
    const dueDevices = devicesSnapshot.docs
      .map((doc) => ({
        uid: doc.data().uid,
        token: doc.data().token,
        preferences: preferencesOf(doc.data()),
      }))
      .filter(({ uid, token, preferences }) => {
        if (!uid || !token || !preferences.enabled) return false;
        if (!preferences.importantDates && !preferences.anniversaries) return false;
        const dayOfDue = isDue(preferences.dayOfTime, nowMinutes);
        const reminderDue =
          preferences.reminderEnabled && isDue(preferences.reminderTime, nowMinutes);
        return dayOfDue || reminderDue;
      });

    if (dueDevices.length === 0) return;

    const coupleIds = await coupleIdsByUid(db, uniqueUids(dueDevices));
    const dataByCouple = new Map();
    const messages = [];

    for (const { uid, token, preferences } of dueDevices) {
      const coupleId = coupleIds.get(uid);
      if (!coupleId) continue;
      if (!dataByCouple.has(coupleId)) {
        dataByCouple.set(coupleId, await loadSpecialDaysData(db, coupleId));
      }
      const { importantDates, settings } = dataByCouple.get(coupleId);

      // --- Jour J ---
      if (isDue(preferences.dayOfTime, nowMinutes)) {
        const lines = specialDayLines({ day: today, importantDates, settings, preferences });
        if (lines.length > 0) {
          messages.push({
            token,
            notification: { title: "Aujourd'hui 💝", body: lines.join(" · ") },
          });
        }
      }

      // --- Rappel X jours avant ---
      if (preferences.reminderEnabled && isDue(preferences.reminderTime, nowMinutes)) {
        const day = addDays(today, preferences.reminderDaysBefore);
        const lines = specialDayLines({ day, importantDates, settings, preferences });
        if (lines.length > 0) {
          messages.push({
            token,
            notification: {
              title: reminderTitle(preferences.reminderDaysBefore),
              body: lines.join(" · "),
            },
          });
        }
      }
    }

    if (messages.length > 0) await getMessaging().sendEach(messages);
  }
);
