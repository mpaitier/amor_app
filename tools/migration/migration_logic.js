// ============================================================================
// MIGRATION : LOGIQUE PURE
// ============================================================================
// Fonctions sans Firebase utilisées par migrate_to_couple.js, testées avec
// node --test.

const STORAGE_HOST = "firebasestorage.googleapis.com";

// --- "Titi:uid1,Lulu:uid2" -> { Titi: "uid1", Lulu: "uid2" } ---
function parseAuthorMap(value) {
  const map = {};
  if (!value) return map;
  for (const pair of value.split(",")) {
    const [name, uid] = pair.split(":").map((part) => (part || "").trim());
    if (!name || !uid) throw new Error(`Association invalide : "${pair}"`);
    map[name] = uid;
  }
  return map;
}

// --- Arguments --nom=valeur et --drapeau ---
function parseArgs(argv) {
  const args = {};
  for (const raw of argv) {
    if (!raw.startsWith("--")) continue;
    const [key, ...rest] = raw.slice(2).split("=");
    args[key] = rest.length > 0 ? rest.join("=") : true;
  }
  return args;
}

// --- Lien de téléchargement Firebase Storage -> { bucket, path }, ou null
// --- pour tout autre lien (Imgur, GIPHY...) ---
function parseStorageUrl(url) {
  let parsed;
  try {
    parsed = new URL(url);
  } catch (error) {
    return null;
  }
  if (parsed.hostname !== STORAGE_HOST) return null;
  const match = parsed.pathname.match(/^\/v0\/b\/([^/]+)\/o\/(.+)$/);
  if (!match) return null;
  return { bucket: match[1], path: decodeURIComponent(match[2]) };
}

// --- Nouvel emplacement d'une image dans la relation. Les dossiers
// --- amor_events/ deviennent events/ ; le reste est rangé sous legacy/ ---
function targetStoragePath(coupleId, oldPath) {
  const prefix = `couples/${coupleId}/`;
  if (oldPath.startsWith(prefix)) return oldPath;
  if (oldPath.startsWith("amor_events/")) {
    return `${prefix}events/${oldPath.slice("amor_events/".length)}`;
  }
  return `${prefix}legacy/${oldPath}`;
}

// --- Lien de téléchargement avec jeton, au format de getDownloadURL ---
function downloadUrl(bucket, path, token) {
  return `https://${STORAGE_HOST}/v0/b/${bucket}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

// --- Liens séparés par "|" dans le champ imageUrl des souvenirs ---
function splitImageUrls(imageUrl) {
  if (!imageUrl) return [];
  return imageUrl.split("|").map((url) => url.trim()).filter(Boolean);
}

// --- Souvenir copié dans la relation : "who" remplacé par creatorUid ---
function migratedEventData(data, { authorMap, imageUrl }) {
  const { who, ...rest } = data;
  const creatorUid = who ? authorMap[who] || "" : rest.creatorUid || "";
  return { ...rest, imageUrl, creatorUid };
}

module.exports = {
  parseAuthorMap,
  parseArgs,
  parseStorageUrl,
  targetStoragePath,
  downloadUrl,
  splitImageUrls,
  migratedEventData,
};
