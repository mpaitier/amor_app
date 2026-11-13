// ============================================================================
// COLOR HISTORY REPOSITORY (INTERFACE)
// ============================================================================
// Couleurs personnalisées déjà utilisées sur ce téléphone, de la plus
// récente à la plus ancienne, pour un usage donné (bordure ou fond).
// Entiers ARGB, sans dépendance à Flutter.

import '../entities/color_history_kind.dart';

abstract class ColorHistoryRepository {
  Future<List<int>> getRecentColors(ColorHistoryKind kind);

  // --- Ajoute une couleur en tête et renvoie la liste à jour ---
  Future<List<int>> addRecentColor(ColorHistoryKind kind, int color);

  // --- Retire une couleur et renvoie la liste à jour ---
  Future<List<int>> removeRecentColor(ColorHistoryKind kind, int color);
}
