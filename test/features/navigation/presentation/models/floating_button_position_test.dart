// ============================================================================
// TEST UNITAIRE : FloatingButtonPosition (géométrie pure)
// ============================================================================
// Écran de 390 × 780 : le centre d'un bouton collé à un bord est à 44 px de
// ce bord, et se déplace sur 390 - 88 = 302 px en largeur, 780 - 88 = 692 px
// en hauteur.

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/navigation/presentation/models/floating_button_position.dart';

void main() {
  const area = Size(390, 780);

  group('centerIn', () {
    test('doit placer le bouton des pages dans le coin bas-droite au départ',
        () {
      expect(
        FloatingButtonPosition.navigationDefault.centerIn(area),
        const Offset(346, 736),
      );
    });

    test('doit placer le bouton d\'ajout dans le coin bas-gauche au départ',
        () {
      expect(
        FloatingButtonPosition.addDefault.centerIn(area),
        const Offset(44, 736),
      );
    });

    test('doit suivre la fraction le long d\'un bord vertical', () {
      expect(
        const FloatingButtonPosition(ScreenEdge.right, 0.5).centerIn(area),
        const Offset(346, 390),
      );
    });

    test('doit suivre la fraction le long d\'un bord horizontal', () {
      expect(
        const FloatingButtonPosition(ScreenEdge.top, 0).centerIn(area),
        const Offset(44, 44),
      );
      expect(
        const FloatingButtonPosition(ScreenEdge.bottom, 0.5).centerIn(area),
        const Offset(195, 736),
      );
    });

    test('doit rester juste quand l\'écran change de taille', () {
      const position = FloatingButtonPosition(ScreenEdge.right, 0.5);

      expect(position.centerIn(const Size(780, 390)), const Offset(736, 195));
    });
  });

  group('snap', () {
    test('doit coller au bord gauche un bouton lâché près de lui', () {
      final position = FloatingButtonPosition.snap(const Offset(60, 390), area);

      expect(position.edge, ScreenEdge.left);
      expect(position.fraction, closeTo(0.5, 0.0001));
    });

    test('doit coller au bord droit en gardant la hauteur', () {
      final position =
          FloatingButtonPosition.snap(const Offset(300, 217), area);

      expect(position.edge, ScreenEdge.right);
      expect(position.fraction, closeTo((217 - 44) / 692, 0.0001));
    });

    test('doit coller au bord haut un bouton lâché tout en haut', () {
      final position = FloatingButtonPosition.snap(const Offset(195, 20), area);

      expect(position.edge, ScreenEdge.top);
      expect(position.fraction, closeTo(0.5, 0.0001));
    });

    test('doit coller au bord bas un bouton lâché tout en bas', () {
      final position =
          FloatingButtonPosition.snap(const Offset(195, 770), area);

      expect(position.edge, ScreenEdge.bottom);
    });

    test('doit ramener dans la marge un bouton lâché dans un coin', () {
      final position = FloatingButtonPosition.snap(const Offset(385, 778), area);

      expect(position.centerIn(area), const Offset(346, 736));
    });
  });
}
