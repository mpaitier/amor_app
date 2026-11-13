// ============================================================================
// TEST UNITAIRE : RadialMenuLayout (géométrie pure)
// ============================================================================
// Écran de 390 × 780, bouton de 56 à 16 px des bords : son centre est à
// 44 px du bord. Rayon de 112 le long d'un bord, de 140 dans un coin.

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/navigation/presentation/models/radial_menu_layout.dart';

void main() {
  const area = Size(390, 780);

  List<Offset> layoutAt(Offset anchor, {int count = 3}) {
    return RadialMenuLayout.offsets(count: count, anchor: anchor, area: area);
  }

  void expectOffsets(List<Offset> actual, List<Offset> expected) {
    expect(actual, hasLength(expected.length));
    for (var i = 0; i < expected.length; i++) {
      expect(actual[i].dx, closeTo(expected[i].dx, 0.01), reason: 'x de $i');
      expect(actual[i].dy, closeTo(expected[i].dy, 0.01), reason: 'y de $i');
    }
  }

  test('coin bas-droite : quart de cercle, du haut vers la gauche', () {
    expectOffsets(layoutAt(const Offset(346, 736)), const [
      Offset(0, -140),
      Offset(-98.995, -98.995),
      Offset(-140, 0),
    ]);
  });

  test('coin haut-gauche : quart de cercle, de la droite vers le bas', () {
    expectOffsets(layoutAt(const Offset(44, 44)), const [
      Offset(140, 0),
      Offset(98.995, 98.995),
      Offset(0, 140),
    ]);
  });

  test('bord droit : arc ouvert vers la gauche, de haut en bas', () {
    expectOffsets(layoutAt(const Offset(346, 390)), const [
      Offset(-56, -96.995),
      Offset(-112, 0),
      Offset(-56, 96.995),
    ]);
  });

  test('bord gauche : arc ouvert vers la droite, de haut en bas', () {
    expectOffsets(layoutAt(const Offset(44, 390)), const [
      Offset(56, -96.995),
      Offset(112, 0),
      Offset(56, 96.995),
    ]);
  });

  test('bord bas : arc ouvert vers le haut, de gauche à droite', () {
    expectOffsets(layoutAt(const Offset(195, 736)), const [
      Offset(-96.995, -56),
      Offset(0, -112),
      Offset(96.995, -56),
    ]);
  });

  test('chaque entrée est à la même distance du bouton', () {
    for (final offset in layoutAt(const Offset(346, 390))) {
      expect(offset.distance, closeTo(RadialMenuLayout.defaultRadius, 0.01));
    }
  });

  test('dans un coin, deux entrées voisines ne se chevauchent pas', () {
    // --- Entrées de 96 × 96 : il suffit qu'elles soient écartées d'au
    // --- moins 96 px en largeur ou en hauteur ---
    final offsets = layoutAt(const Offset(346, 736));
    for (var i = 0; i < offsets.length - 1; i++) {
      final gap = offsets[i + 1] - offsets[i];
      expect(
        gap.dx.abs() >= 96 || gap.dy.abs() >= 96,
        isTrue,
        reason: 'entrées $i et ${i + 1}',
      );
    }
  });

  test('une seule entrée : face à l\'intérieur de l\'écran', () {
    expectOffsets(layoutAt(const Offset(346, 390), count: 1), const [
      Offset(-112, 0),
    ]);
  });

  test('aucune entrée : liste vide', () {
    expect(layoutAt(const Offset(346, 736), count: 0), isEmpty);
  });
}
