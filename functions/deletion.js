// ============================================================================
// SUPPRESSIONS
// ============================================================================
// Effacement complet d'une relation, et d'un compte avec tout ce qui lui
// est rattaché. Utilisé par la suppression de compte, la fin de relation
// et le nettoyage des relations inactives.

const { FieldValue } = require("firebase-admin/firestore");
const { getStorage } = require("firebase-admin/storage");
const { getAuth } = require("firebase-admin/auth");

// --- Relation : sous-collections (souvenirs, dates, réglages), images
// --- Storage, code d'invitation. Les membres repartent sans relation ---
async function deleteCoupleCompletely(db, coupleId) {
  const coupleRef = db.collection("couples").doc(coupleId);
  const coupleDoc = await coupleRef.get();
  const data = coupleDoc.exists ? coupleDoc.data() : {};
  const members = data.members || [];

  await Promise.all(
    members.map((uid) =>
      db.collection("users").doc(uid).set(
        { coupleId: FieldValue.delete(), updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      ),
    ),
  );

  if (data.inviteCode) {
    await db.collection("invites").doc(data.inviteCode).delete();
  }

  await getStorage().bucket().deleteFiles({ prefix: `couples/${coupleId}/` });
  await db.recursiveDelete(coupleRef);

  return members;
}

// --- Compte : document users, téléphones rattachés, compte
// --- d'authentification ---
async function deleteUserEverywhere(db, uid) {
  const devices = await db.collection("device_tokens").where("uid", "==", uid).get();
  await Promise.all(devices.docs.map((doc) => doc.ref.delete()));
  await db.collection("users").doc(uid).delete();

  try {
    await getAuth().deleteUser(uid);
  } catch (error) {
    // --- Déjà supprimé (deuxième appel, suppression depuis la console) ---
    if (error.code !== "auth/user-not-found") throw error;
  }
}

module.exports = { deleteCoupleCompletely, deleteUserEverywhere };
