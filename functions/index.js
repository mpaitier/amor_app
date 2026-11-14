const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
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

initializeApp();

// ============================================================================
// RELATIONS (création, adhésion par code)
// ============================================================================

const { createCouple, joinCouple } = require("./couples");
exports.createCouple = createCouple;
exports.joinCouple = joinCouple;

// ============================================================================
// NOUVEAU SOUVENIR
// ============================================================================
// Prévient les autres appareils, s'ils ont gardé ce type de notification.

exports.notifyOnNewMemory = onDocumentCreated(
  "timeline_events/{eventId}",
  async (event) => {
    const eventData = event.data.data();
    const title = eventData.title || "Nouveau souvenir";
    const who = eventData.who || "";
    const creatorDeviceId = eventData.creatorDeviceId || null;

    const db = getFirestore();
    const tokensSnapshot = await db.collection("device_tokens").get();

    // --- On exclut l'appareil qui vient de créer le souvenir, et ceux qui
    // --- ont coupé ces notifications ---
    const tokens = tokensSnapshot.docs
      .filter((doc) => doc.id !== creatorDeviceId)
      .filter((doc) => {
        const preferences = preferencesOf(doc.data());
        return preferences.enabled && preferences.newMemory;
      })
      .map((doc) => doc.data().token)
      .filter((token) => !!token);

    if (tokens.length === 0) return;

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
// JOURS SPÉCIAUX (DATES IMPORTANTES ET ANNIVERSAIRES)
// ============================================================================
// Passe toutes les 5 minutes. Pour chaque appareil dont l'heure du jour J ou
// du rappel tombe dans ce créneau, envoie la liste des jours spéciaux
// concernés, selon ses préférences.

// --- Charge les dates importantes et les réglages du couple ---
async function loadSpecialDaysData(db) {
  const [datesSnapshot, settingsDoc] = await Promise.all([
    db.collection("important_dates").get(),
    db.collection("app_settings").doc("couple").get(),
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

exports.notifySpecialDays = onSchedule(
  { schedule: "every 5 minutes", timeZone: "Europe/Paris" },
  async () => {
    const db = getFirestore();
    const now = parisParts(new Date());
    const today = { y: now.y, m: now.m, d: now.d };
    const nowMinutes = now.hour * 60 + now.minute;

    // --- Appareils qui ont quelque chose à recevoir dans ce créneau ---
    const devicesSnapshot = await db.collection("device_tokens").get();
    const dueDevices = devicesSnapshot.docs
      .map((doc) => ({ token: doc.data().token, preferences: preferencesOf(doc.data()) }))
      .filter(({ token, preferences }) => {
        if (!token || !preferences.enabled) return false;
        if (!preferences.importantDates && !preferences.anniversaries) return false;
        const dayOfDue = isDue(preferences.dayOfTime, nowMinutes);
        const reminderDue =
          preferences.reminderEnabled && isDue(preferences.reminderTime, nowMinutes);
        return dayOfDue || reminderDue;
      });

    if (dueDevices.length === 0) return;

    const { importantDates, settings } = await loadSpecialDaysData(db);
    const messages = [];

    for (const { token, preferences } of dueDevices) {
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
