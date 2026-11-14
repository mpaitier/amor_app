// ============================================================================
// ENVOI DE NOTIFICATIONS
// ============================================================================
// Appareils rattachés à des comptes (device_tokens.uid) et envoi d'une même
// notification à tous ces comptes.

const { getMessaging } = require("firebase-admin/messaging");
const { chunk } = require("./recipients");

// --- Appareils des comptes donnés. Les requêtes "in" acceptent 30 valeurs
// --- au plus ---
async function devicesOfUids(db, uids) {
  const devices = [];
  for (const ids of chunk(uids, 30)) {
    const snapshot = await db.collection("device_tokens").where("uid", "in", ids).get();
    for (const doc of snapshot.docs) devices.push({ id: doc.id, ...doc.data() });
  }
  return devices;
}

// --- Notification envoyée à tous les appareils des comptes donnés, sans
// --- tenir compte des préférences : réservé aux messages qui concernent le
// --- compte lui-même (fin de relation, suppression prochaine) ---
async function sendToUids(db, uids, notification) {
  if (uids.length === 0) return;
  const tokens = (await devicesOfUids(db, uids))
    .map((device) => device.token)
    .filter((token) => !!token);
  if (tokens.length === 0) return;
  await getMessaging().sendEachForMulticast({ notification, tokens });
}

module.exports = { devicesOfUids, sendToUids };
