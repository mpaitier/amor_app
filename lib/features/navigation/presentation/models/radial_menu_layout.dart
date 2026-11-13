// ============================================================================
// RADIAL MENU LAYOUT (UI MODEL)
// ============================================================================
// Place les entrées du menu en arc autour du bouton, tournées vers
// l'intérieur de l'écran :
// - dans un coin, sur un quart de cercle ;
// - le long d'un bord, sur un arc plus ouvert, face au centre.
// La première entrée de la liste (le journal) part de l'extrémité de l'arc
// la plus haute (à hauteur égale, celle de gauche), puis on suit l'arc.
// Calcul pur, en coordonnées d'écran (y vers le bas).

import 'dart:math' as math;
import 'dart:ui';

class RadialMenuLayout {
  const RadialMenuLayout._();

  // --- Distance entre le centre du bouton et celui de chaque entrée ---
  static const double defaultRadius = 112;

  // --- Part de l'écran, depuis un bord, considérée comme "près du bord" ---
  static const double _sideRatioX = 0.3;
  static const double _sideRatioY = 0.25;

  // --- Ouverture de l'arc dans un coin et le long d'un bord ---
  static const double _cornerSpread = math.pi / 2;
  static const double _edgeSpread = 2 * math.pi / 3;

  // --- Décalage de chaque entrée par rapport au centre du bouton, dans
  // --- l'ordre de la liste ---
  static List<Offset> offsets({
    required int count,
    required Offset anchor,
    required Size area,
    double radius = defaultRadius,
  }) {
    if (count <= 0) return const [];

    // --- Direction vers l'intérieur de l'écran ---
    var directionX = 0.0;
    if (anchor.dx < area.width * _sideRatioX) directionX = 1;
    if (anchor.dx > area.width * (1 - _sideRatioX)) directionX = -1;

    var directionY = 0.0;
    if (anchor.dy < area.height * _sideRatioY) directionY = 1;
    if (anchor.dy > area.height * (1 - _sideRatioY)) directionY = -1;

    // --- En plein milieu, le menu s'ouvre vers le haut ---
    if (directionX == 0 && directionY == 0) directionY = -1;

    final isCorner = directionX != 0 && directionY != 0;
    final centerAngle = math.atan2(directionY, directionX);
    final spread = count == 1 ? 0.0 : (isCorner ? _cornerSpread : _edgeSpread);

    final positions = <Offset>[
      for (var i = 0; i < count; i++)
        _pointAt(
          count == 1
              ? centerAngle
              : centerAngle - spread / 2 + spread * i / (count - 1),
          radius,
        ),
    ];

    // --- On part de l'extrémité la plus haute ; à hauteur égale, de celle
    // --- de gauche ---
    final first = positions.first;
    final last = positions.last;
    final startsAtLast =
        last.dy < first.dy || (last.dy == first.dy && last.dx < first.dx);
    return startsAtLast ? positions.reversed.toList() : positions;
  }

  static Offset _pointAt(double angle, double radius) {
    // --- Arrondi : évite des -0.0000001 qui faussent le tri ---
    double round(double value) => (value * 1000).roundToDouble() / 1000;
    return Offset(
      round(math.cos(angle) * radius),
      round(math.sin(angle) * radius),
    );
  }
}
