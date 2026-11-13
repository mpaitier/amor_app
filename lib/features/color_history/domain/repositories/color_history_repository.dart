// ============================================================================
// COLOR HISTORY REPOSITORY (INTERFACE)
// ============================================================================
// Couleurs personnalisées déjà utilisées sur ce téléphone, de la plus
// récente à la plus ancienne. Entiers ARGB, sans dépendance à Flutter.

abstract class ColorHistoryRepository {
  Future<List<int>> getRecentColors();

  // --- Ajoute une couleur en tête et renvoie la liste à jour ---
  Future<List<int>> addRecentColor(int color);
}
