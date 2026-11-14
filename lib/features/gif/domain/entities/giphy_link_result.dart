// ============================================================================
// GIPHY LINK RESULT
// ============================================================================
// Issue de la lecture d'un lien collé par l'utilisateur : soit l'adresse de
// l'image GIF à afficher, soit la raison du refus. Modèle de domaine pur,
// sans Flutter : les messages affichés sont choisis par la présentation.

// --- Pourquoi un lien a été refusé ---
enum GiphyLinkRejection {
  // --- Champ vide ---
  empty,

  // --- Texte qui n'est pas une adresse web ---
  notALink,

  // --- Adresse d'un autre site que GIPHY ---
  notGiphy,

  // --- Adresse GIPHY qui ne mène pas à un GIF (page d'accueil, recherche,
  // --- vidéo .mp4...) ---
  notAGif,
}

sealed class GiphyLinkResult {
  const GiphyLinkResult();
}

// --- Lien accepté : adresse directe de l'image, prête pour Image.network ---
class GiphyLinkAccepted extends GiphyLinkResult {
  final String gifUrl;

  const GiphyLinkAccepted(this.gifUrl);

  @override
  bool operator ==(Object other) {
    return other is GiphyLinkAccepted && other.gifUrl == gifUrl;
  }

  @override
  int get hashCode => gifUrl.hashCode;
}

// --- Lien refusé, avec sa raison ---
class GiphyLinkRejected extends GiphyLinkResult {
  final GiphyLinkRejection reason;

  const GiphyLinkRejected(this.reason);

  @override
  bool operator ==(Object other) {
    return other is GiphyLinkRejected && other.reason == reason;
  }

  @override
  int get hashCode => reason.hashCode;
}
