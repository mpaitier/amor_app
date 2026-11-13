// ============================================================================
// TEST UNITAIRE : ImportantDateEntity (logique pure, aucun mock nécessaire)
// ============================================================================
// Couvre la répétition : quels jours portent la date selon sa fréquence, et
// quelle est sa prochaine occurrence. Le calendrier s'appuie dessus pour
// savoir jusqu'où s'étendre.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';

void main() {
  ImportantDateEntity buildDate(
    DateTime date,
    ImportantDateRecurrence recurrence,
  ) {
    return ImportantDateEntity(
      id: 'd1',
      title: 'Anniversaire',
      date: date,
      emoji: '🎂',
      recurrence: recurrence,
    );
  }

  group('repeats', () {
    test('doit être faux pour une date ponctuelle', () {
      final date = buildDate(DateTime(2026, 12, 28), ImportantDateRecurrence.none);

      expect(date.repeats, isFalse);
    });

    test('doit être vrai dès qu\'une fréquence est choisie', () {
      final date =
          buildDate(DateTime(2026, 12, 28), ImportantDateRecurrence.monthly);

      expect(date.repeats, isTrue);
    });
  });

  group('occursOn, date ponctuelle', () {
    final date = buildDate(DateTime(2026, 12, 28), ImportantDateRecurrence.none);

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

  group('occursOn, tous les ans', () {
    final date =
        buildDate(DateTime(2023, 12, 12), ImportantDateRecurrence.yearly);

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

  group('occursOn, tous les mois', () {
    final date =
        buildDate(DateTime(2026, 1, 31), ImportantDateRecurrence.monthly);

    test('doit revenir le même jour les mois suivants', () {
      expect(date.occursOn(DateTime(2026, 3, 31)), isTrue);
    });

    test('doit être ramenée au dernier jour des mois plus courts', () {
      expect(date.occursOn(DateTime(2026, 2, 28)), isTrue);
      expect(date.occursOn(DateTime(2026, 4, 30)), isTrue);
    });

    test('ne doit pas tomber un autre jour du mois', () {
      expect(date.occursOn(DateTime(2026, 3, 30)), isFalse);
    });

    test('ne doit pas exister avant sa première fois', () {
      expect(date.occursOn(DateTime(2025, 12, 31)), isFalse);
    });
  });

  group('occursOn, toutes les semaines', () {
    // --- Le 5 novembre 2026 est un jeudi ---
    final date =
        buildDate(DateTime(2026, 11, 5), ImportantDateRecurrence.weekly);

    test('doit revenir le même jour de la semaine', () {
      expect(date.occursOn(DateTime(2026, 11, 12)), isTrue);
      expect(date.occursOn(DateTime(2027, 1, 7)), isTrue);
    });

    test('ne doit pas tomber un autre jour de la semaine', () {
      expect(date.occursOn(DateTime(2026, 11, 13)), isFalse);
    });

    test('ne doit pas exister avant sa première fois', () {
      expect(date.occursOn(DateTime(2026, 10, 29)), isFalse);
    });
  });

  group('29 février répété tous les ans', () {
    final date =
        buildDate(DateTime(2024, 2, 29), ImportantDateRecurrence.yearly);

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
      final date =
          buildDate(DateTime(2026, 12, 28), ImportantDateRecurrence.none);

      expect(date.nextOccurrence(today), DateTime(2026, 12, 28));
    });

    test('doit renvoyer aujourd\'hui si c\'est le jour même', () {
      final date =
          buildDate(DateTime(2026, 11, 13), ImportantDateRecurrence.none);

      expect(date.nextOccurrence(today), DateTime(2026, 11, 13));
    });

    test('doit renvoyer null si le jour est passé', () {
      final date =
          buildDate(DateTime(2026, 11, 12), ImportantDateRecurrence.none);

      expect(date.nextOccurrence(today), isNull);
    });
  });

  group('nextOccurrence, tous les ans', () {
    final today = DateTime(2026, 11, 13);

    test('doit renvoyer l\'occurrence de cette année si elle reste à venir',
        () {
      final date =
          buildDate(DateTime(2023, 12, 12), ImportantDateRecurrence.yearly);

      expect(date.nextOccurrence(today), DateTime(2026, 12, 12));
    });

    test('doit passer à l\'année suivante si celle de cette année est passée',
        () {
      final date =
          buildDate(DateTime(2024, 3, 3), ImportantDateRecurrence.yearly);

      expect(date.nextOccurrence(today), DateTime(2027, 3, 3));
    });

    test('doit renvoyer aujourd\'hui si l\'occurrence tombe aujourd\'hui', () {
      final date =
          buildDate(DateTime(2020, 11, 13), ImportantDateRecurrence.yearly);

      expect(date.nextOccurrence(today), DateTime(2026, 11, 13));
    });

    test('doit renvoyer la première fois si elle n\'a pas encore eu lieu', () {
      final date =
          buildDate(DateTime(2028, 6, 1), ImportantDateRecurrence.yearly);

      expect(date.nextOccurrence(today), DateTime(2028, 6, 1));
    });
  });

  group('nextOccurrence, tous les mois', () {
    test('doit renvoyer l\'occurrence de ce mois si elle reste à venir', () {
      final date =
          buildDate(DateTime(2026, 1, 31), ImportantDateRecurrence.monthly);

      expect(
        date.nextOccurrence(DateTime(2026, 11, 13)),
        DateTime(2026, 11, 30),
      );
    });

    test('doit passer au mois suivant si celle de ce mois est passée', () {
      final date =
          buildDate(DateTime(2026, 1, 5), ImportantDateRecurrence.monthly);

      expect(
        date.nextOccurrence(DateTime(2026, 11, 13)),
        DateTime(2026, 12, 5),
      );
    });

    test('doit changer d\'année en décembre', () {
      final date =
          buildDate(DateTime(2026, 1, 5), ImportantDateRecurrence.monthly);

      expect(
        date.nextOccurrence(DateTime(2026, 12, 20)),
        DateTime(2027, 1, 5),
      );
    });
  });

  group('nextOccurrence, toutes les semaines', () {
    // --- Le 5 novembre 2026 est un jeudi, le 13 un vendredi ---
    final date =
        buildDate(DateTime(2026, 11, 5), ImportantDateRecurrence.weekly);

    test('doit renvoyer le prochain même jour de la semaine', () {
      expect(
        date.nextOccurrence(DateTime(2026, 11, 13)),
        DateTime(2026, 11, 19),
      );
    });

    test('doit renvoyer aujourd\'hui si c\'est le bon jour', () {
      expect(
        date.nextOccurrence(DateTime(2026, 11, 12)),
        DateTime(2026, 11, 12),
      );
    });

    test('doit passer sur le mois suivant en fin de mois', () {
      expect(
        date.nextOccurrence(DateTime(2026, 11, 27)),
        DateTime(2026, 12, 3),
      );
    });
  });

  group('limite d\'occurrences', () {
    ImportantDateEntity limited(
      DateTime date,
      ImportantDateRecurrence recurrence,
      int limit,
    ) {
      return buildDate(date, recurrence).copyWith(occurrenceLimit: () => limit);
    }

    test('doit tomber les fois prévues puis s\'arrêter, chaque année', () {
      final date = limited(DateTime(2024, 6, 1), ImportantDateRecurrence.yearly, 3);

      expect(date.occursOn(DateTime(2024, 6, 1)), isTrue);
      expect(date.occursOn(DateTime(2026, 6, 1)), isTrue);
      expect(date.occursOn(DateTime(2027, 6, 1)), isFalse);
    });

    test('doit compter les mois pour une date mensuelle', () {
      final date =
          limited(DateTime(2026, 11, 5), ImportantDateRecurrence.monthly, 2);

      expect(date.occursOn(DateTime(2026, 12, 5)), isTrue);
      expect(date.occursOn(DateTime(2027, 1, 5)), isFalse);
    });

    test('doit compter les semaines pour une date hebdomadaire', () {
      // --- Le 5 novembre 2026 est un jeudi ---
      final date =
          limited(DateTime(2026, 11, 5), ImportantDateRecurrence.weekly, 3);

      expect(date.occursOn(DateTime(2026, 11, 19)), isTrue);
      expect(date.occursOn(DateTime(2026, 11, 26)), isFalse);
    });

    test('doit renvoyer null comme prochaine fois une fois la limite atteinte',
        () {
      final date = limited(DateTime(2024, 6, 1), ImportantDateRecurrence.yearly, 2);

      expect(date.nextOccurrence(DateTime(2024, 12, 1)), DateTime(2025, 6, 1));
      expect(date.nextOccurrence(DateTime(2025, 7, 1)), isNull);
    });

    test('doit être ignorée pour une date ponctuelle', () {
      final date = limited(DateTime(2026, 12, 28), ImportantDateRecurrence.none, 2);

      expect(date.occursOn(DateTime(2026, 12, 28)), isTrue);
    });

    test('doit pouvoir être retirée avec copyWith', () {
      final date = limited(DateTime(2024, 6, 1), ImportantDateRecurrence.yearly, 2);

      final copy = date.copyWith(occurrenceLimit: () => null);

      expect(copy.occurrenceLimit, isNull);
      expect(copy.occursOn(DateTime(2030, 6, 1)), isTrue);
    });
  });

  group('copyWith', () {
    test('doit ne remplacer que les champs fournis', () {
      final date =
          buildDate(DateTime(2026, 12, 28), ImportantDateRecurrence.none);

      final copy = date.copyWith(
        title: 'Noël en famille',
        recurrence: ImportantDateRecurrence.yearly,
        borderColor: 0xFF2E8B57,
      );

      expect(copy.title, 'Noël en famille');
      expect(copy.recurrence, ImportantDateRecurrence.yearly);
      expect(copy.borderColor, 0xFF2E8B57);
      expect(copy.id, date.id);
      expect(copy.date, date.date);
      expect(copy.emoji, date.emoji);
      expect(copy.backgroundColor, date.backgroundColor);
    });
  });

  test('doit appliquer les couleurs par défaut quand aucune n\'est fournie', () {
    final date =
        buildDate(DateTime(2026, 12, 28), ImportantDateRecurrence.none);

    expect(date.backgroundColor, ImportantDateEntity.defaultBackgroundColor);
    expect(date.borderColor, ImportantDateEntity.defaultBorderColor);
  });
}
