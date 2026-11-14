// ============================================================================
// TESTS : migration_logic.js (node --test)
// ============================================================================

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  parseAuthorMap,
  parseArgs,
  parseStorageUrl,
  targetStoragePath,
  downloadUrl,
  splitImageUrls,
  migratedEventData,
} = require("./migration_logic");

const BUCKET = "amor-app-9ee55.firebasestorage.app";

test("parseAuthorMap : associe chaque surnom à un uid", () => {
  assert.deepEqual(parseAuthorMap("Titi:uid-1, Lulu:uid-2"), {
    Titi: "uid-1",
    Lulu: "uid-2",
  });
  assert.deepEqual(parseAuthorMap(undefined), {});
  assert.throws(() => parseAuthorMap("Titi"));
});

test("parseArgs : valeurs et drapeaux", () => {
  assert.deepEqual(parseArgs(["--couple=abc", "--apply", "seul"]), {
    couple: "abc",
    apply: true,
  });
  assert.deepEqual(parseArgs(["--map=Titi:a=b"]), { map: "Titi:a=b" });
});

test("parseStorageUrl : lit le chemin d'un lien Storage", () => {
  const url =
    `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/` +
    "amor_events%2Frome%2F123_photo.jpg?alt=media&token=abc";
  assert.deepEqual(parseStorageUrl(url), {
    bucket: BUCKET,
    path: "amor_events/rome/123_photo.jpg",
  });
});

test("parseStorageUrl : ignore les autres liens", () => {
  assert.equal(parseStorageUrl("https://i.imgur.com/abc.png"), null);
  assert.equal(parseStorageUrl("pas un lien"), null);
});

test("targetStoragePath : range les images sous la relation", () => {
  assert.equal(
    targetStoragePath("c1", "amor_events/rome/1.jpg"),
    "couples/c1/events/rome/1.jpg",
  );
  assert.equal(
    targetStoragePath("c1", "imports/2023/1.jpg"),
    "couples/c1/legacy/imports/2023/1.jpg",
  );
  assert.equal(
    targetStoragePath("c1", "couples/c1/events/a.jpg"),
    "couples/c1/events/a.jpg",
  );
});

test("downloadUrl : encode le chemin comme getDownloadURL", () => {
  assert.equal(
    downloadUrl(BUCKET, "couples/c1/events/a b.jpg", "tok"),
    `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/` +
      "couples%2Fc1%2Fevents%2Fa%20b.jpg?alt=media&token=tok",
  );
});

test("downloadUrl puis parseStorageUrl retrouvent le chemin", () => {
  const path = "couples/c1/events/weekend_à_rome/1.jpg";
  assert.equal(parseStorageUrl(downloadUrl(BUCKET, path, "t")).path, path);
});

test("splitImageUrls : sépare et nettoie", () => {
  assert.deepEqual(splitImageUrls(" a | b |"), ["a", "b"]);
  assert.deepEqual(splitImageUrls(""), []);
  assert.deepEqual(splitImageUrls(undefined), []);
});

test("migratedEventData : remplace who par creatorUid", () => {
  const data = { title: "Rome", who: "Lulu", imageUrl: "old", place: "Rome" };
  const result = migratedEventData(data, {
    authorMap: { Lulu: "uid-lulu" },
    imageUrl: "new",
  });
  assert.deepEqual(result, {
    title: "Rome",
    place: "Rome",
    imageUrl: "new",
    creatorUid: "uid-lulu",
  });
});

test("migratedEventData : auteur inconnu -> creatorUid vide", () => {
  const result = migratedEventData(
    { title: "Rome", who: "Inconnu" },
    { authorMap: {}, imageUrl: "" },
  );
  assert.equal(result.creatorUid, "");
  assert.equal("who" in result, false);
});
