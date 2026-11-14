// ============================================================================
// LOOPING IMAGE INDEX
// ============================================================================
// Passage d'une image à l'autre en boucle dans la visionneuse : après la
// dernière revient la première, et inversement.
// Le PageView de la visionneuse n'a pas de fin : ses pages sont numérotées
// sans limite et chacune affiche l'image "page modulo nombre d'images". On
// démarre loin de la page 0 pour pouvoir reculer longtemps. Ainsi la boucle
// se fait avec la même animation qu'un passage ordinaire.

class LoopingImageIndex {
  // --- Nombre de tours d'avance au départ : de quoi reculer sans jamais
  // --- atteindre la page 0 en pratique ---
  static const int _startLaps = 1000;

  final int imageCount;

  const LoopingImageIndex(this.imageCount)
      : assert(imageCount > 0, 'Il faut au moins une image');

  // --- Une seule image : ni flèches ni glissement ---
  bool get canNavigate => imageCount > 1;

  // --- Page de départ qui montre l'image touchée ---
  int initialPage(int imageIndex) {
    if (!canNavigate) return 0;
    return _startLaps * imageCount + imageIndex.clamp(0, imageCount - 1);
  }

  // --- Image affichée par une page. Le modulo de Dart reste positif, même
  // --- pour une page négative ---
  int imageIndexOf(int page) => page % imageCount;
}
