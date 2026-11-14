// ============================================================================
// READABLE TEXT COLOR
// ============================================================================
// Une couleur choisie librement (le jaune de Lulu, par exemple) peut être
// illisible en texte sur fond clair. Cette fonction garde la teinte mais
// l'assombrit jusqu'à un contraste suffisant avec le blanc. Une couleur
// déjà assez foncée est rendue telle quelle.

import 'package:flutter/painting.dart';

// --- Contraste visé avec le blanc : 3:1, le minimum des recommandations
// --- d'accessibilité (WCAG) pour un texte en gras ---
const double _defaultContrast = 3.0;

// --- Pas d'assombrissement : petit pour rester proche de la couleur ---
const double _lightnessStep = 0.02;

Color readableTextColor(Color color, {double contrast = _defaultContrast}) {
  // --- Contraste avec le blanc = 1.05 / (luminance + 0.05) ---
  final maxLuminance = 1.05 / contrast - 0.05;
  if (color.computeLuminance() <= maxLuminance) return color;

  var hsl = HSLColor.fromColor(color);
  while (hsl.lightness > 0) {
    final lightness = (hsl.lightness - _lightnessStep).clamp(0.0, 1.0);
    hsl = hsl.withLightness(lightness);
    if (hsl.toColor().computeLuminance() <= maxLuminance) break;
  }
  return hsl.toColor().withValues(alpha: color.a);
}
