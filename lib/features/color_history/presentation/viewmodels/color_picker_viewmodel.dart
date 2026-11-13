// ============================================================================
// COLOR PICKER VIEWMODEL
// ============================================================================
// État du sélecteur de couleur : la teinte, la saturation et la luminosité
// en cours, et les couleurs récentes de ce téléphone.

import 'package:flutter/material.dart';
import '../../domain/usecases/add_recent_color.dart';
import '../../domain/usecases/get_recent_colors.dart';

class ColorPickerViewModel extends ChangeNotifier {
  final GetRecentColors _getRecentColors;
  final AddRecentColor _addRecentColor;

  // --- State ---
  HSVColor _color;
  List<int> _recentColors = const [];
  bool _isDisposed = false;

  ColorPickerViewModel({
    required GetRecentColors getRecentColors,
    required AddRecentColor addRecentColor,
    required int initialColor,
  })  : _getRecentColors = getRecentColors,
        _addRecentColor = addRecentColor,
        _color = HSVColor.fromColor(Color(initialColor)) {
    _loadRecentColors();
  }

  // --- Getters ---
  HSVColor get color => _color;
  int get colorValue => _color.toColor().toARGB32();
  List<int> get recentColors => _recentColors;

  // --- "#7B4FD6", pour l'aperçu ---
  String get hexLabel {
    final rgb = colorValue & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void setHue(double hue) {
    _color = _color.withHue(hue.clamp(0.0, 360.0));
    notifyListeners();
  }

  void setSaturationValue(double saturation, double value) {
    _color = _color
        .withSaturation(saturation.clamp(0.0, 1.0))
        .withValue(value.clamp(0.0, 1.0));
    notifyListeners();
  }

  void selectRecentColor(int color) {
    _color = HSVColor.fromColor(Color(color));
    notifyListeners();
  }

  // --- Valide la couleur : elle rejoint l'historique, puis est renvoyée.
  // --- Un historique qui ne s'enregistre pas n'empêche pas le choix ---
  Future<int> confirm() async {
    final value = colorValue;
    try {
      _recentColors = await _addRecentColor(value);
    } catch (_) {
      // --- L'historique n'est qu'un confort ---
    }
    return value;
  }

  Future<void> _loadRecentColors() async {
    try {
      final colors = await _getRecentColors();
      if (_isDisposed) return;
      _recentColors = colors;
      notifyListeners();
    } catch (_) {
      // --- Sans historique, le sélecteur reste utilisable ---
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
