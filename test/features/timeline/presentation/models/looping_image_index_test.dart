// ============================================================================
// TEST UNITAIRE : LoopingImageIndex
// ============================================================================
// Ouverture sur l'image touchée et navigation en boucle de la visionneuse.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/timeline/presentation/models/looping_image_index.dart';

void main() {
  group('plusieurs images', () {
    const index = LoopingImageIndex(4);

    test('doit permettre la navigation', () {
      expect(index.canNavigate, isTrue);
    });

    test('doit ouvrir sur l\'image touchée', () {
      for (var image = 0; image < 4; image++) {
        expect(index.imageIndexOf(index.initialPage(image)), image);
      }
    });

    test('doit passer de la dernière image à la première', () {
      final lastPage = index.initialPage(3);
      expect(index.imageIndexOf(lastPage + 1), 0);
    });

    test('doit passer de la première image à la dernière', () {
      final firstPage = index.initialPage(0);
      expect(index.imageIndexOf(firstPage - 1), 3);
    });

    test('doit enchaîner les tours dans les deux sens', () {
      final start = index.initialPage(1);
      expect(index.imageIndexOf(start + 4), 1);
      expect(index.imageIndexOf(start + 9), 2);
      expect(index.imageIndexOf(start - 6), 3);
    });

    test('doit pouvoir reculer longtemps sans page négative', () {
      expect(index.initialPage(0), greaterThan(1000));
    });

    test('doit ramener un index hors limites dans la liste', () {
      expect(index.imageIndexOf(index.initialPage(9)), 3);
      expect(index.imageIndexOf(index.initialPage(-2)), 0);
    });

    test('doit rester positif pour une page négative', () {
      expect(index.imageIndexOf(-1), 3);
    });
  });

  group('une seule image', () {
    const index = LoopingImageIndex(1);

    test('ne doit permettre ni flèches ni glissement', () {
      expect(index.canNavigate, isFalse);
    });

    test('doit ouvrir sur la page 0', () {
      expect(index.initialPage(0), 0);
      expect(index.imageIndexOf(0), 0);
    });
  });

  group('deux images', () {
    const index = LoopingImageIndex(2);

    test('doit alterner dans les deux sens', () {
      final start = index.initialPage(0);
      expect(index.imageIndexOf(start + 1), 1);
      expect(index.imageIndexOf(start + 2), 0);
      expect(index.imageIndexOf(start - 1), 1);
    });
  });
}
