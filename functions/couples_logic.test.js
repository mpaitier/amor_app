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
  parseDayString,
  dayToNoonUtc,
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

test("parseDayString : lit une date AAAA-MM-JJ", () => {
  assert.deepEqual(parseDayString("2023-12-12"), { y: 2023, m: 12, d: 12 });
});

test("parseDayString : refuse une date mal formée ou inexistante", () => {
  assert.equal(parseDayString("12/12/2023"), null);
  assert.equal(parseDayString("2023-02-31"), null);
  assert.equal(parseDayString("2023-13-01"), null);
  assert.equal(parseDayString(20231212), null);
  assert.equal(parseDayString(undefined), null);
});

test("parseDayString : refuse une date après aujourd'hui", () => {
  const today = { y: 2026, m: 11, d: 14 };
  assert.deepEqual(parseDayString("2026-11-14", today), { y: 2026, m: 11, d: 14 });
  assert.equal(parseDayString("2026-11-15", today), null);
});

test("dayToNoonUtc : midi UTC du jour donné", () => {
  assert.equal(
    dayToNoonUtc({ y: 2023, m: 12, d: 12 }).toISOString(),
    "2023-12-12T12:00:00.000Z",
  );
});
