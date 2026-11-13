// ============================================================================
// COLOR PICKER VIEWMODEL
// ============================================================================
// État du sélecteur de couleur : la teinte, la saturation et la luminosité
// en cours. L'historique est tenu à part, par RecentColorsViewModel.

import 'package:flutter/material.dart';

class ColorPickerViewModel extends ChangeNotifier {
  HSVColor _color;

  ColorPickerViewModel({required int initialColor})
      : _color = HSVColor.fromColor(Color(initialColor));

  // --- Getters ---
  HSVColor get color => _color;
  int get colorValue => _color.toColor().toARGB32();

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
}
