// ============================================================================
// DESTINATAIRES : LOGIQUE PURE
// ============================================================================
// Petites fonctions sans Firebase pour choisir qui reçoit une notification,
// testées avec node --test.

// --- Découpe une liste en paquets (les requêtes Firestore "in" acceptent
// --- 30 valeurs au plus) ---
function chunk(items, size) {
  const chunks = [];
  for (let i = 0; i < items.length; i += size) {
    chunks.push(items.slice(i, i + size));
  }
  return chunks;
}

// --- Surnom d'un membre dans le document de la relation, "" si inconnu ---
function memberNickname(couple, uid) {
  if (!couple || !uid) return "";
  const profiles = couple.profiles || {};
  const profile = profiles[uid];
  return profile && typeof profile.nickname === "string" ? profile.nickname : "";
}

// --- Un appareil doit-il être prévenu d'un souvenir ? Pas celui qui l'a
// --- créé, ni aucun appareil du compte de son auteur ---
function isOtherMembersDevice(device, { creatorUid, creatorDeviceId }) {
  if (creatorDeviceId && device.id === creatorDeviceId) return false;
  if (creatorUid && device.uid === creatorUid) return false;
  return true;
}

// --- uid distincts, sans les valeurs vides ---
function uniqueUids(devices) {
  return [...new Set(devices.map((device) => device.uid).filter(Boolean))];
}

module.exports = {
  chunk,
  memberNickname,
  isOtherMembersDevice,
  uniqueUids,
};
