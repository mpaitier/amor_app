const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.notifyOnNewMemory = onDocumentCreated(
  "timeline_events/{eventId}",
  async (event) => {
    const eventData = event.data.data();
    const title = eventData.title || "Nouveau souvenir";
    const who = eventData.who || "";

    const db = getFirestore();
    const tokensSnapshot = await db.collection("device_tokens").get();

    // --- Version simple : on prend TOUS les tokens, sans filtre ---
    const tokens = tokensSnapshot.docs
      .map((doc) => doc.data().token)
      .filter((token) => !!token);

    if (tokens.length === 0) return;

    const body = who
      ? `${who} vient d'ajouter "${title}"`
      : `Un nouveau souvenir a été ajouté : "${title}"`;

    await getMessaging().sendEachForMulticast({
      notification: {
        title: "Nouveau souvenir \u2764\ufe0f",
        body,
      },
      tokens,
    });
  }
);