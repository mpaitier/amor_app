// ============================================================================
// TEST UNITAIRE : CurrentCouple
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/core/session/current_couple.dart';

void main() {
  late CurrentCouple currentCouple;

  setUp(() {
    currentCouple = CurrentCouple();
  });

  test('sans relation, id lève une exception', () {
    expect(currentCouple.idOrNull, isNull);
    expect(() => currentCouple.id,
        throwsA(isA<NoCurrentCoupleException>()));
  });

  test('un identifiant vide compte comme pas de relation', () {
    currentCouple.set('');
    expect(() => currentCouple.id,
        throwsA(isA<NoCurrentCoupleException>()));
  });

  test('path range le chemin sous la relation', () {
    currentCouple.set('couple-1');

    expect(currentCouple.id, 'couple-1');
    expect(currentCouple.path('timeline_events'),
        'couples/couple-1/timeline_events');
  });

  test('set(null) oublie la relation', () {
    currentCouple.set('couple-1');
    currentCouple.set(null);

    expect(currentCouple.idOrNull, isNull);
  });
}
