// ============================================================================
// TEST UNITAIRE : CalendarMonth (logique pure, aucun mock nécessaire)
// ============================================================================
// Couvre le découpage d'un mois en semaines (lundi en premier) et
// l'arithmétique entre mois, sur lesquels repose tout le calendrier.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/calendar/domain/entities/calendar_month.dart';

void main() {
  group('dayCount', () {
    test('doit compter 29 jours en février d\'une année bissextile', () {
      expect(const CalendarMonth(2024, 2).dayCount, 29);
    });

    test('doit compter 28 jours en février d\'une année ordinaire', () {
      expect(const CalendarMonth(2026, 2).dayCount, 28);
    });

    test('doit compter 31 jours en décembre', () {
      expect(const CalendarMonth(2026, 12).dayCount, 31);
    });
  });

  group('leadingEmptyDays', () {
    test('doit laisser 3 cases vides quand le mois commence un jeudi', () {
      expect(const CalendarMonth(2026, 10).leadingEmptyDays, 3);
    });

    test('doit laisser 6 cases vides quand le mois commence un dimanche', () {
      expect(const CalendarMonth(2026, 11).leadingEmptyDays, 6);
    });

    test('ne doit laisser aucune case vide quand le mois commence un lundi',
        () {
      expect(const CalendarMonth(2027, 2).leadingEmptyDays, 0);
    });
  });

  group('weekCount', () {
    test('doit valoir 5 pour octobre 2026', () {
      expect(const CalendarMonth(2026, 10).weekCount, 5);
    });

    test('doit valoir 6 pour novembre 2026, qui commence un dimanche', () {
      expect(const CalendarMonth(2026, 11).weekCount, 6);
    });

    test('doit valoir 4 pour février 2027, qui tient en 4 semaines pleines',
        () {
      expect(const CalendarMonth(2027, 2).weekCount, 4);
    });
  });

  group('weeks', () {
    test('doit renvoyer des semaines de 7 cases', () {
      final weeks = const CalendarMonth(2026, 10).weeks;

      expect(weeks, hasLength(5));
      expect(weeks.every((week) => week.length == 7), isTrue);
    });

    test('doit placer le 1er sous son jour et laisser null avant', () {
      final firstWeek = const CalendarMonth(2026, 10).weeks.first;

      expect(firstWeek, [
        null,
        null,
        null,
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 4),
      ]);
    });

    test('doit compléter la dernière semaine avec null', () {
      final lastWeek = const CalendarMonth(2026, 10).weeks.last;

      expect(lastWeek.first, DateTime(2026, 10, 26));
      expect(lastWeek[5], DateTime(2026, 10, 31));
      expect(lastWeek.last, isNull);
    });
  });

  group('addMonths', () {
    test('doit reculer sur l\'année précédente', () {
      expect(
        const CalendarMonth(2026, 1).addMonths(-1),
        const CalendarMonth(2025, 12),
      );
    });

    test('doit avancer sur l\'année suivante', () {
      expect(
        const CalendarMonth(2026, 11).addMonths(2),
        const CalendarMonth(2027, 1),
      );
    });

    test('doit traverser plusieurs années', () {
      expect(
        const CalendarMonth(2026, 11).addMonths(-23),
        const CalendarMonth(2024, 12),
      );
    });

    test('doit renvoyer le même mois pour un décalage nul', () {
      expect(
        const CalendarMonth(2026, 11).addMonths(0),
        const CalendarMonth(2026, 11),
      );
    });
  });

  group('monthsUntil', () {
    test('doit être positif vers un mois plus récent', () {
      expect(
        const CalendarMonth(2025, 12).monthsUntil(const CalendarMonth(2026, 11)),
        11,
      );
    });

    test('doit être négatif vers un mois plus ancien', () {
      expect(
        const CalendarMonth(2026, 11).monthsUntil(const CalendarMonth(2025, 12)),
        -11,
      );
    });
  });

  group('comparaison', () {
    test('doit ordonner deux mois d\'années différentes', () {
      const older = CalendarMonth(2025, 12);
      const newer = CalendarMonth(2026, 1);

      expect(older.isBefore(newer), isTrue);
      expect(newer.isAfter(older), isTrue);
      expect(older.isAfter(newer), isFalse);
    });

    test('doit considérer égaux deux mois identiques', () {
      expect(const CalendarMonth(2026, 11), const CalendarMonth(2026, 11));
      expect(
        const CalendarMonth(2026, 11).hashCode,
        const CalendarMonth(2026, 11).hashCode,
      );
    });

    test('doit ignorer le jour et l\'heure dans fromDate', () {
      expect(
        CalendarMonth.fromDate(DateTime(2026, 11, 12, 15, 30)),
        const CalendarMonth(2026, 11),
      );
    });
  });
}
