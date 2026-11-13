// ============================================================================
// FLOATING BUTTON POSITION (UI MODEL)
// ============================================================================
// Place d'un bouton flottant, toujours collé à un bord de l'écran : le bord,
// et la position le long de ce bord (0 = début, 1 = fin, en laissant la
// marge). Indépendante de la taille de l'écran, elle reste juste après une
// rotation ou l'ouverture du clavier. Calcul pur, coordonnées d'écran.

import 'dart:ui';

enum ScreenEdge { left, right, top, bottom }

class FloatingButtonPosition {
  // --- Distance entre le centre du bouton et le bord : marge de 16 plus la
  // --- moitié d'un bouton de 56 ---
  static const double inset = 44;

  final ScreenEdge edge;
  final double fraction;

  const FloatingButtonPosition(this.edge, this.fraction);

  // --- Positions de départ, reprises à chaque lancement de l'app ---
  static const FloatingButtonPosition navigationDefault =
      FloatingButtonPosition(ScreenEdge.right, 1);
  static const FloatingButtonPosition addDefault =
      FloatingButtonPosition(ScreenEdge.left, 1);

  // --- Centre du bouton dans une zone donnée ---
  Offset centerIn(Size area) {
    final along = fraction.clamp(0.0, 1.0);
    final x = inset + along * _span(area.width);
    final y = inset + along * _span(area.height);

    switch (edge) {
      case ScreenEdge.left:
        return Offset(inset, y);
      case ScreenEdge.right:
        return Offset(area.width - inset, y);
      case ScreenEdge.top:
        return Offset(x, inset);
      case ScreenEdge.bottom:
        return Offset(x, area.height - inset);
    }
  }

  // --- Colle un bouton lâché au bord le plus proche, en gardant sa
  // --- position le long de ce bord ---
  static FloatingButtonPosition snap(Offset center, Size area) {
    final distances = {
      ScreenEdge.left: center.dx,
      ScreenEdge.right: area.width - center.dx,
      ScreenEdge.top: center.dy,
      ScreenEdge.bottom: area.height - center.dy,
    };
    final edge = distances.entries
        .reduce((closest, entry) => entry.value < closest.value ? entry : closest)
        .key;

    final isVerticalEdge = edge == ScreenEdge.left || edge == ScreenEdge.right;
    final along = isVerticalEdge
        ? _fraction(center.dy, area.height)
        : _fraction(center.dx, area.width);
    return FloatingButtonPosition(edge, along);
  }

  // --- Longueur utile d'un bord, marges retirées ---
  static double _span(double length) {
    final span = length - 2 * inset;
    return span > 0 ? span : 0;
  }

  static double _fraction(double coordinate, double length) {
    final span = _span(length);
    if (span == 0) return 0;
    return ((coordinate - inset) / span).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) {
    return other is FloatingButtonPosition &&
        other.edge == edge &&
        other.fraction == fraction;
  }

  @override
  int get hashCode => Object.hash(edge, fraction);
}
