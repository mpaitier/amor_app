// ============================================================================
// TEST UNITAIRE : intitulés d'anniversaire (fonctions pures)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/settings/domain/utils/anniversary_titles.dart';

void main() {
  test('doit écrire 1er pour le premier anniversaire', () {
    expect(anniversaryTitle(1), '1er anniversaire');
  });

  test('doit écrire e pour les suivants', () {
    expect(anniversaryTitle(3), '3e anniversaire');
    expect(anniversaryTitle(10), '10e anniversaire');
  });

  test('doit nommer un mois-anniversaire par son nombre de mois', () {
    expect(monthAnniversaryTitle(1), '1 mois');
    expect(monthAnniversaryTitle(35), '35 mois');
  });
}
