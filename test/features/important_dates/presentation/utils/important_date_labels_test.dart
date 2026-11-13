// ============================================================================
// TEST UNITAIRE : libellés d'une date importante (fonctions pures)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';
import 'package:amor_app/features/important_dates/presentation/utils/important_date_labels.dart';

void main() {
  final today = DateTime(2026, 11, 13, 10, 55);

  group('formatCountdown', () {
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
  });

  group('formatShortCountdown', () {
    test('doit donner le nombre de jours restants en toutes lettres', () {
      expect(formatShortCountdown(DateTime(2026, 12, 28), today), '45 jours');
    });

    test('doit écrire jour au singulier la veille', () {
      expect(formatShortCountdown(DateTime(2026, 11, 14), today), '1 jour');
    });

    test('doit annoncer le jour J', () {
      expect(formatShortCountdown(DateTime(2026, 11, 13), today), 'Jour J');
    });

    test('doit signaler une date qui ne reviendra plus', () {
      expect(formatShortCountdown(null, today), 'Passée');
    });

    test('doit signaler un jour déjà passé', () {
      expect(formatShortCountdown(DateTime(2026, 11, 3), today), 'Passée');
    });
  });

  group('recurrenceLabel', () {
    test('doit nommer chaque fréquence', () {
      expect(
        recurrenceLabel(ImportantDateRecurrence.yearly),
        'Tous les ans',
      );
      expect(
        recurrenceLabel(ImportantDateRecurrence.monthly),
        'Tous les mois',
      );
      expect(
        recurrenceLabel(ImportantDateRecurrence.weekly),
        'Toutes les semaines',
      );
      expect(
        recurrenceLabel(ImportantDateRecurrence.none),
        'Une seule fois',
      );
    });
  });

  group('occurrenceCountLabel', () {
    test('doit compter en années, avec le pluriel', () {
      expect(occurrenceCountLabel(ImportantDateRecurrence.yearly, 1), '1 an');
      expect(occurrenceCountLabel(ImportantDateRecurrence.yearly, 9), '9 ans');
    });

    test('doit compter en mois, invariable', () {
      expect(occurrenceCountLabel(ImportantDateRecurrence.monthly, 1), '1 mois');
      expect(
        occurrenceCountLabel(ImportantDateRecurrence.monthly, 12),
        '12 mois',
      );
    });

    test('doit compter en semaines, avec le pluriel', () {
      expect(
        occurrenceCountLabel(ImportantDateRecurrence.weekly, 1),
        '1 semaine',
      );
      expect(
        occurrenceCountLabel(ImportantDateRecurrence.weekly, 3),
        '3 semaines',
      );
    });
  });

  group('recurrenceSummary', () {
    test('doit exprimer la limite dans l\'unité de la fréquence', () {
      expect(
        recurrenceSummary(ImportantDateRecurrence.yearly, 9),
        'Tous les ans, pendant 9 ans',
      );
      expect(
        recurrenceSummary(ImportantDateRecurrence.weekly, 4),
        'Toutes les semaines, pendant 4 semaines',
      );
    });

    test('doit se limiter à la fréquence sans limite', () {
      expect(
        recurrenceSummary(ImportantDateRecurrence.yearly, null),
        'Tous les ans',
      );
    });

    test('doit ajouter le nombre de fois quand il y a une limite', () {
      expect(
        recurrenceSummary(ImportantDateRecurrence.monthly, 5),
        'Tous les mois, pendant 5 mois',
      );
    });

    test('doit ignorer la limite d\'une date ponctuelle', () {
      expect(
        recurrenceSummary(ImportantDateRecurrence.none, 5),
        'Une seule fois',
      );
    });
  });
}
