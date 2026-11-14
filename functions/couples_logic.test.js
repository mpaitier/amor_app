// ============================================================================
// TESTS : couples_logic.js (node --test)
// ============================================================================

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  INVITE_ALPHABET,
  INVITE_LENGTH,
  generateInviteCode,
  normalizeInviteCode,
  validateProfile,
} = require("./couples_logic");

test("generateInviteCode : longueur fixe, caractères de l'alphabet", () => {
  const code = generateInviteCode((max) => Math.floor(Math.random() * max));
  assert.equal(code.length, INVITE_LENGTH);
  for (const char of code) assert.ok(INVITE_ALPHABET.includes(char));
});

test("generateInviteCode : suit le générateur fourni", () => {
  assert.equal(generateInviteCode(() => 0), "AAAAAA");
});

test("l'alphabet évite les caractères ambigus", () => {
  for (const char of ["0", "O", "1", "I", "L"]) {
    assert.ok(!INVITE_ALPHABET.includes(char), char);
  }
});

test("normalizeInviteCode : accepte minuscules, espaces et tirets", () => {
  assert.equal(normalizeInviteCode("K7PQ2A"), "K7PQ2A");
  assert.equal(normalizeInviteCode("k7pq2a"), "K7PQ2A");
  assert.equal(normalizeInviteCode(" k7p q2a "), "K7PQ2A");
  assert.equal(normalizeInviteCode("k7p-q2a"), "K7PQ2A");
});

test("normalizeInviteCode : refuse une mauvaise longueur", () => {
  assert.equal(normalizeInviteCode("K7PQ2"), null);
  assert.equal(normalizeInviteCode("K7PQ2AB"), null);
  assert.equal(normalizeInviteCode(""), null);
});

test("normalizeInviteCode : refuse les caractères hors alphabet", () => {
  assert.equal(normalizeInviteCode("K7PQ20"), null);
  assert.equal(normalizeInviteCode("K7PQ2I"), null);
  assert.equal(normalizeInviteCode(42), null);
  assert.equal(normalizeInviteCode(undefined), null);
});

test("validateProfile : nettoie le surnom", () => {
  assert.deepEqual(
    validateProfile({ nickname: "  Titi ", color: 0xff7b4fd6 }),
    { nickname: "Titi", color: 0xff7b4fd6 },
  );
});

test("validateProfile : refuse un surnom vide ou trop long", () => {
  assert.equal(validateProfile({ nickname: "   ", color: 0xff7b4fd6 }), null);
  assert.equal(validateProfile({ nickname: "x".repeat(31), color: 0xff7b4fd6 }), null);
});

test("validateProfile : refuse une couleur invalide", () => {
  assert.equal(validateProfile({ nickname: "Lulu", color: "jaune" }), null);
  assert.equal(validateProfile({ nickname: "Lulu", color: -1 }), null);
  assert.equal(validateProfile({ nickname: "Lulu", color: 1.5 }), null);
  assert.equal(validateProfile({ nickname: "Lulu" }), null);
  assert.equal(validateProfile(null), null);
});
