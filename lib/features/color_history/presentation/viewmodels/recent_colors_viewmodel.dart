// ============================================================================
// RECENT COLORS VIEWMODEL
// ============================================================================
// Couleurs libres récentes de ce téléphone, une liste pour les bordures et
// une pour les fonds. Fourni par les écrans qui ont des rangées de couleurs
// (formulaire des dates importantes, paramètres).

import 'package:flutter/foundation.dart';
import '../../domain/entities/color_history_kind.dart';
import '../../domain/usecases/add_recent_color.dart';
import '../../domain/usecases/get_recent_colors.dart';

class RecentColorsViewModel extends ChangeNotifier {
  final GetRecentColors _getRecentColors;
  final AddRecentColor _addRecentColor;

  // --- State ---
  final Map<ColorHistoryKind, List<int>> _colors = {
    for (final kind in ColorHistoryKind.values) kind: const [],
  };
  bool _isDisposed = false;

  RecentColorsViewModel({
    required GetRecentColors getRecentColors,
    required AddRecentColor addRecentColor,
  })  : _getRecentColors = getRecentColors,
        _addRecentColor = addRecentColor {
    _load();
  }

  // --- De la plus récente à la plus ancienne ---
  List<int> colorsFor(ColorHistoryKind kind) => _colors[kind] ?? const [];

  // --- Retient une couleur libre qui vient d'être choisie ---
  Future<void> addColor(ColorHistoryKind kind, int color) async {
    try {
      final updated = await _addRecentColor(kind, color);
      if (_isDisposed) return;
      _colors[kind] = updated;
      notifyListeners();
    } catch (_) {
      // --- L'historique n'est qu'un confort ---
    }
  }

  Future<void> _load() async {
    for (final kind in ColorHistoryKind.values) {
      try {
        final colors = await _getRecentColors(kind);
        if (_isDisposed) return;
        _colors[kind] = colors;
      } catch (_) {
        // --- Sans historique, les rangées restent utilisables ---
      }
    }
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
