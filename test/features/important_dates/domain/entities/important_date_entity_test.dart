// ============================================================================
// TEST UNITAIRE : ImportantDateEntity (logique pure, aucun mock nécessaire)
// ============================================================================
// Couvre la répétition annuelle : quels jours portent la date, et quelle est
// sa prochaine occurrence. Le calendrier s'appuie dessus pour savoir jusqu'où
// s'étendre.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';

void main() {
  ImportantDateEntity buildDate(DateTime date, {required bool repeatsYearly}) {
    return ImportantDateEntity(
      id: 'd1',
      title: 'Anniversaire',
      date: date,
      emoji: '🎂',
      repeatsYearly: repeatsYearly,
    );
  }

  group('occursOn, date ponctuelle', () {
    final date = buildDate(DateTime(2026, 12, 28), repeatsYearly: false);

    test('doit tomber le jour prévu, quelle que soit l\'heure', () {
      expect(date.occursOn(DateTime(2026, 12, 28, 18, 30)), isTrue);
    });

    test('ne doit pas tomber un autre jour', () {
      expect(date.occursOn(DateTime(2026, 12, 27)), isFalse);
    });

    test('ne doit pas revenir l\'année suivante', () {
      expect(date.occursOn(DateTime(2027, 12, 28)), isFalse);
    });
  });

  group('occursOn, date répétée', () {
    final date = buildDate(DateTime(2023, 12, 12), repeatsYearly: true);

    test('doit tomber la première année', () {
      expect(date.occursOn(DateTime(2023, 12, 12)), isTrue);
    });

    test('doit revenir les années suivantes', () {
      expect(date.occursOn(DateTime(2026, 12, 12)), isTrue);
    });

    test('ne doit pas exister avant sa première année', () {
      expect(date.occursOn(DateTime(2022, 12, 12)), isFalse);
    });

    test('ne doit pas tomber un autre jour', () {
      expect(date.occursOn(DateTime(2026, 12, 13)), isFalse);
    });
  });

  group('29 février répété', () {
    final date = buildDate(DateTime(2024, 2, 29), repeatsYearly: true);

    test('doit retomber le 28 février une année ordinaire', () {
      expect(date.occurrenceInYear(2025), DateTime(2025, 2, 28));
      expect(date.occursOn(DateTime(2025, 2, 28)), isTrue);
    });

    test('doit retomber le 29 février une année bissextile', () {
      expect(date.occurrenceInYear(2028), DateTime(2028, 2, 29));
      expect(date.occursOn(DateTime(2028, 2, 29)), isTrue);
      expect(date.occursOn(DateTime(2028, 2, 28)), isFalse);
    });
  });

  group('nextOccurrence, date ponctuelle', () {
    final today = DateTime(2026, 11, 13, 10);

    test('doit renvoyer le jour prévu s\'il est à venir', () {
      final date = buildDate(DateTime(2026, 12, 28), repeatsYearly: false);

      expect(date.nextOccurrence(today), DateTime(2026, 12, 28));
    });

    test('doit renvoyer aujourd\'hui si c\'est le jour même', () {
      final date = buildDate(DateTime(2026, 11, 13), repeatsYearly: false);

      expect(date.nextOccurrence(today), DateTime(2026, 11, 13));
    });

    test('doit renvoyer null si le jour est passé', () {
      final date = buildDate(DateTime(2026, 11, 12), repeatsYearly: false);

      expect(date.nextOccurrence(today), isNull);
    });
  });

  group('nextOccurrence, date répétée', () {
    final today = DateTime(2026, 11, 13);

    test('doit renvoyer l\'occurrence de cette année si elle reste à venir',
        () {
      final date = buildDate(DateTime(2023, 12, 12), repeatsYearly: true);

      expect(date.nextOccurrence(today), DateTime(2026, 12, 12));
    });

    test('doit passer à l\'année suivante si celle de cette année est passée',
        () {
      final date = buildDate(DateTime(2024, 3, 3), repeatsYearly: true);

      expect(date.nextOccurrence(today), DateTime(2027, 3, 3));
    });

    test('doit renvoyer aujourd\'hui si l\'occurrence tombe aujourd\'hui', () {
      final date = buildDate(DateTime(2020, 11, 13), repeatsYearly: true);

      expect(date.nextOccurrence(today), DateTime(2026, 11, 13));
    });

    test('doit renvoyer la première fois si elle n\'a pas encore eu lieu', () {
      final date = buildDate(DateTime(2028, 6, 1), repeatsYearly: true);

      expect(date.nextOccurrence(today), DateTime(2028, 6, 1));
    });
  });

  group('copyWith', () {
    test('doit ne remplacer que les champs fournis', () {
      final date = buildDate(DateTime(2026, 12, 28), repeatsYearly: false);

      final copy = date.copyWith(title: 'Noël en famille', borderColor: 0xFF2E8B57);

      expect(copy.title, 'Noël en famille');
      expect(copy.borderColor, 0xFF2E8B57);
      expect(copy.id, date.id);
      expect(copy.date, date.date);
      expect(copy.emoji, date.emoji);
      expect(copy.repeatsYearly, date.repeatsYearly);
      expect(copy.backgroundColor, date.backgroundColor);
    });
  });

  test('doit appliquer les couleurs par défaut quand aucune n\'est fournie', () {
    final date = buildDate(DateTime(2026, 12, 28), repeatsYearly: false);

    expect(date.backgroundColor, ImportantDateEntity.defaultBackgroundColor);
    expect(date.borderColor, ImportantDateEntity.defaultBorderColor);
  });
}
