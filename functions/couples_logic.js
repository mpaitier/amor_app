// ============================================================================
// RELATIONS : LOGIQUE PURE
// ============================================================================
// Codes d'invitation et vérification des profils, sans Firebase, pour être
// testés avec node --test.

// --- Ni 0/O ni 1/I/L : un code se lit à voix haute ou se recopie sans
// --- hésitation ---
const INVITE_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
const INVITE_LENGTH = 6;
const NICKNAME_MAX_LENGTH = 30;

// --- randomInt(max) renvoie un entier dans [0, max[ ---
function generateInviteCode(randomInt) {
  let code = "";
  for (let i = 0; i < INVITE_LENGTH; i++) {
    code += INVITE_ALPHABET[randomInt(INVITE_ALPHABET.length)];
  }
  return code;
}

// --- Majuscules, sans espaces ni tirets. null si le résultat ne peut pas
// --- être un code ---
function normalizeInviteCode(input) {
  if (typeof input !== "string") return null;
  const code = input.toUpperCase().replace(/[\s-]/g, "");
  if (code.length !== INVITE_LENGTH) return null;
  for (const char of code) {
    if (!INVITE_ALPHABET.includes(char)) return null;
  }
  return code;
}

// --- Surnom non vide et couleur ARGB. Renvoie le profil nettoyé, ou null
// --- s'il n'est pas valable ---
function validateProfile(data) {
  if (!data || typeof data !== "object") return null;
  const nickname = typeof data.nickname === "string" ? data.nickname.trim() : "";
  if (nickname.length === 0 || nickname.length > NICKNAME_MAX_LENGTH) return null;
  const color = data.color;
  if (!Number.isInteger(color) || color < 0 || color > 0xffffffff) return null;
  return { nickname, color };
}

module.exports = {
  INVITE_ALPHABET,
  INVITE_LENGTH,
  NICKNAME_MAX_LENGTH,
  generateInviteCode,
  normalizeInviteCode,
  validateProfile,
};
