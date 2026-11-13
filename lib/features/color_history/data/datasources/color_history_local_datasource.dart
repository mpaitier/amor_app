// ============================================================================
// COLOR HISTORY LOCAL DATA SOURCE
// ============================================================================
// Stocke les couleurs récentes dans les SharedPreferences : quelques
// entiers propres à ce téléphone, inutile de les partager via Firestore.
// Une liste par usage : bordures et fonds.

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/color_history_kind.dart';

class ColorHistoryLocalDataSource {
  // --- Ancienne liste unique, reprise tant qu'un usage n'a pas la sienne ---
  static const String _legacyKey = 'recent_custom_colors';

  // --- Au-delà, les plus anciennes sont oubliées ---
  static const int maxColors = 8;

  const ColorHistoryLocalDataSource();

  static String _keyFor(ColorHistoryKind kind) {
    switch (kind) {
      case ColorHistoryKind.border:
        return 'recent_border_colors';
      case ColorHistoryKind.background:
        return 'recent_background_colors';
    }
  }

  Future<List<int>> getRecentColors(ColorHistoryKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_keyFor(kind)) ??
        prefs.getStringList(_legacyKey) ??
        const [];
    return [
      for (final value in stored)
        if (int.tryParse(value) != null) int.parse(value),
    ];
  }

  // --- Place la couleur en tête, sans doublon, puis enregistre ---
  Future<List<int>> addRecentColor(ColorHistoryKind kind, int color) async {
    final colors = await getRecentColors(kind);
    colors.remove(color);
    colors.insert(0, color);
    final kept = colors.take(maxColors).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFor(kind), [for (final c in kept) '$c']);
    return kept;
  }
}
