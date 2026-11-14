// ============================================================================
// TESTS : recipients.js (node --test)
// ============================================================================

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  chunk,
  memberNickname,
  isOtherMembersDevice,
  uniqueUids,
} = require("./recipients");

test("chunk : découpe en paquets de taille fixe", () => {
  assert.deepEqual(chunk([1, 2, 3, 4, 5], 2), [[1, 2], [3, 4], [5]]);
  assert.deepEqual(chunk([], 30), []);
});

test("memberNickname : lit le surnom dans les profils", () => {
  const couple = { profiles: { "uid-titi": { nickname: "Titi", color: 1 } } };
  assert.equal(memberNickname(couple, "uid-titi"), "Titi");
  assert.equal(memberNickname(couple, "uid-lulu"), "");
  assert.equal(memberNickname(couple, ""), "");
  assert.equal(memberNickname({}, "uid-titi"), "");
  assert.equal(memberNickname(null, "uid-titi"), "");
});

test("isOtherMembersDevice : écarte l'appareil et le compte de l'auteur", () => {
  const author = { creatorUid: "uid-titi", creatorDeviceId: "device-1" };
  assert.equal(isOtherMembersDevice({ id: "device-1", uid: "uid-titi" }, author), false);
  assert.equal(isOtherMembersDevice({ id: "device-2", uid: "uid-titi" }, author), false);
  assert.equal(isOtherMembersDevice({ id: "device-3", uid: "uid-lulu" }, author), true);
});

test("isOtherMembersDevice : sans auteur connu, garde tout le monde", () => {
  assert.equal(isOtherMembersDevice({ id: "device-1", uid: "uid-titi" }, {}), true);
});

test("uniqueUids : sans doublons ni valeurs vides", () => {
  const devices = [{ uid: "a" }, { uid: "b" }, { uid: "a" }, { uid: undefined }, {}];
  assert.deepEqual(uniqueUids(devices), ["a", "b"]);
});
