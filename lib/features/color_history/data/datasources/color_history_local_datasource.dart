// ============================================================================
// COLOR HISTORY LOCAL DATA SOURCE
// ============================================================================
// Stocke les couleurs récentes dans les SharedPreferences : quelques
// entiers propres à ce téléphone, inutile de les partager via Firestore.

import 'package:shared_preferences/shared_preferences.dart';

class ColorHistoryLocalDataSource {
  static const String _key = 'recent_custom_colors';

  // --- Au-delà, les plus anciennes sont oubliées ---
  static const int maxColors = 8;

  const ColorHistoryLocalDataSource();

  Future<List<int>> getRecentColors() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key) ?? const [];
    return [
      for (final value in stored)
        if (int.tryParse(value) != null) int.parse(value),
    ];
  }

  // --- Place la couleur en tête, sans doublon, puis enregistre ---
  Future<List<int>> addRecentColor(int color) async {
    final colors = await getRecentColors();
    colors.remove(color);
    colors.insert(0, color);
    final kept = colors.take(maxColors).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, [for (final c in kept) '$c']);
    return kept;
  }
}
