// ============================================================================
// TESTS : couple_lifecycle_logic.js (node --test)
// ============================================================================

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  DAY_MS,
  endRequestProgress,
  membersWithoutAnswer,
  needsEndReminder,
  inactivityAction,
  inactivityQueryCutoffMs,
} = require("./couple_lifecycle_logic");

const NOW = Date.UTC(2027, 5, 1);

test("endRequestProgress : compte les membres actuels qui ont accepté", () => {
  const couple = {
    members: ["a", "b", "c"],
    endRequest: { acceptedBy: ["a", "c"] },
  };
  assert.deepEqual(endRequestProgress(couple), { accepted: 2, total: 3, allAccepted: false });
});

test("endRequestProgress : tout le monde a accepté", () => {
  const couple = { members: ["a", "b"], endRequest: { acceptedBy: ["b", "a"] } };
  assert.equal(endRequestProgress(couple).allAccepted, true);
});

test("endRequestProgress : un ancien membre ne compte plus", () => {
  const couple = { members: ["a"], endRequest: { acceptedBy: ["a", "parti"] } };
  assert.deepEqual(endRequestProgress(couple), { accepted: 1, total: 1, allAccepted: true });
});

test("endRequestProgress : sans demande, personne n'a accepté", () => {
  assert.deepEqual(endRequestProgress({ members: ["a", "b"] }), {
    accepted: 0,
    total: 2,
    allAccepted: false,
  });
  assert.equal(endRequestProgress({ members: [] }).allAccepted, false);
});

test("membersWithoutAnswer : ni accepté ni refusé", () => {
  const couple = {
    members: ["a", "b", "c"],
    endRequest: { acceptedBy: ["a"], declinedBy: ["b"] },
  };
  assert.deepEqual(membersWithoutAnswer(couple), ["c"]);
});

test("needsEndReminder : à partir du 6e jour, une seule fois", () => {
  const requestedAt = NOW - 6 * DAY_MS;
  assert.equal(needsEndReminder({}, requestedAt, NOW), true);
  assert.equal(needsEndReminder({}, NOW - 5 * DAY_MS, NOW), false);
  assert.equal(needsEndReminder({ reminderSentAt: {} }, requestedAt, NOW), false);
  assert.equal(needsEndReminder(null, requestedAt, NOW), false);
  assert.equal(needsEndReminder({}, undefined, NOW), false);
});

test("inactivityAction : rien avant 335 jours", () => {
  assert.equal(inactivityAction(NOW - 334 * DAY_MS, NOW, {}), null);
});

test("inactivityAction : avertissement à J-30", () => {
  assert.deepEqual(inactivityAction(NOW - 335 * DAY_MS, NOW, {}), { warn: "d30", daysLeft: 30 });
  assert.equal(inactivityAction(NOW - 340 * DAY_MS, NOW, { d30: true }), null);
});

test("inactivityAction : avertissement à J-7", () => {
  assert.deepEqual(inactivityAction(NOW - 358 * DAY_MS, NOW, { d30: true }), {
    warn: "d7",
    daysLeft: 7,
  });
  assert.equal(inactivityAction(NOW - 360 * DAY_MS, NOW, { d30: true, d7: true }), null);
});

test("inactivityAction : J-7 passe avant J-30 si les deux sont dus", () => {
  assert.deepEqual(inactivityAction(NOW - 359 * DAY_MS, NOW, {}), { warn: "d7", daysLeft: 7 });
});

test("inactivityAction : suppression à 365 jours", () => {
  assert.equal(inactivityAction(NOW - 365 * DAY_MS, NOW, { d30: true, d7: true }), "delete");
  assert.equal(inactivityAction(NOW - 400 * DAY_MS, NOW, {}), "delete");
});

test("inactivityAction : sans date d'activité, rien", () => {
  assert.equal(inactivityAction(undefined, NOW, {}), null);
});

test("inactivityQueryCutoffMs : 335 jours en arrière", () => {
  assert.equal(inactivityQueryCutoffMs(NOW), NOW - 335 * DAY_MS);
});
