// ============================================================================
// TEST UNITAIRE : formatCountdown (fonction pure)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/important_dates/presentation/utils/important_date_labels.dart';

void main() {
  final today = DateTime(2026, 11, 13, 10, 55);

  test('doit annoncer aujourd\'hui, quelle que soit l\'heure', () {
    expect(formatCountdown(DateTime(2026, 11, 13), today), 'Aujourd\'hui');
  });

  test('doit annoncer demain', () {
    expect(formatCountdown(DateTime(2026, 11, 14), today), 'Demain');
  });

  test('doit annoncer hier', () {
    expect(formatCountdown(DateTime(2026, 11, 12), today), 'Hier');
  });

  test('doit compter les jours restants', () {
    expect(formatCountdown(DateTime(2026, 12, 28), today), 'Dans 45 jours');
  });

  test('doit compter les jours écoulés', () {
    expect(formatCountdown(DateTime(2026, 11, 3), today), 'Il y a 10 jours');
  });

  test('doit compter juste à travers le changement d\'heure de mars', () {
    expect(
      formatCountdown(DateTime(2027, 4, 1), DateTime(2027, 3, 25)),
      'Dans 7 jours',
    );
  });
}
