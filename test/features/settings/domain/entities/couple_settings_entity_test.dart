// ============================================================================
// TEST UNITAIRE : CoupleSettingsEntity (logique pure, aucun mock nécessaire)
// ============================================================================
// Couvre le calcul des anniversaires et des mois-anniversaires.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';

void main() {
  // --- Début de l'histoire : le 12 décembre 2023 ---
  final settings = CoupleSettingsEntity(
    relationshipStart: DateTime(2023, 12, 12),
  );

  group('defaults', () {
    test('doit reprendre la date de début de app_constants.dart', () {
      final defaults = CoupleSettingsEntity.defaults();

      expect(defaults.relationshipStart, DateTime(2023, 12, 12));
      expect(defaults.showAnniversary, isFalse);
      expect(defaults.showMonthAnniversaries, isFalse);
      expect(defaults.gifSearchTerm, 'hedgehog cute');
      expect(
        defaults.anniversaryStyle,
        CoupleSettingsEntity.defaultAnniversaryStyle,
      );
    });
  });

  group('anniversaryNumberOn', () {
    test('doit compter les années écoulées le jour de l\'anniversaire', () {
      expect(settings.anniversaryNumberOn(DateTime(2024, 12, 12)), 1);
      expect(settings.anniversaryNumberOn(DateTime(2026, 12, 12, 20)), 3);
    });

    test('ne doit pas fêter le jour du début lui-même', () {
      expect(settings.anniversaryNumberOn(DateTime(2023, 12, 12)), isNull);
    });

    test('doit renvoyer null un autre jour', () {
      expect(settings.anniversaryNumberOn(DateTime(2026, 12, 13)), isNull);
    });

    test('doit ramener un 29 février au 28 les années ordinaires', () {
      final leap = CoupleSettingsEntity(
        relationshipStart: DateTime(2024, 2, 29),
      );

      expect(leap.anniversaryNumberOn(DateTime(2025, 2, 28)), 1);
      expect(leap.anniversaryNumberOn(DateTime(2028, 2, 29)), 4);
      expect(leap.anniversaryNumberOn(DateTime(2028, 2, 28)), isNull);
    });
  });

  group('monthAnniversaryNumberOn', () {
    test('doit compter les mois écoulés le bon jour', () {
      expect(settings.monthAnniversaryNumberOn(DateTime(2024, 1, 12)), 1);
      expect(settings.monthAnniversaryNumberOn(DateTime(2026, 11, 12)), 35);
    });

    test('ne doit pas fêter le jour du début lui-même', () {
      expect(settings.monthAnniversaryNumberOn(DateTime(2023, 12, 12)), isNull);
    });

    test('doit renvoyer null un autre jour du mois', () {
      expect(settings.monthAnniversaryNumberOn(DateTime(2026, 11, 13)), isNull);
    });

    test('doit ramener un 31 au dernier jour des mois plus courts', () {
      final endOfMonth = CoupleSettingsEntity(
        relationshipStart: DateTime(2024, 1, 31),
      );

      expect(endOfMonth.monthAnniversaryNumberOn(DateTime(2024, 2, 29)), 1);
      expect(endOfMonth.monthAnniversaryNumberOn(DateTime(2025, 2, 28)), 13);
      expect(endOfMonth.monthAnniversaryNumberOn(DateTime(2024, 4, 30)), 3);
    });
  });

  group('nextAnniversary', () {
    test('doit renvoyer celui de cette année s\'il reste à venir', () {
      expect(
        settings.nextAnniversary(DateTime(2026, 11, 13)),
        DateTime(2026, 12, 12),
      );
    });

    test('doit renvoyer aujourd\'hui le jour même', () {
      expect(
        settings.nextAnniversary(DateTime(2026, 12, 12, 9)),
        DateTime(2026, 12, 12),
      );
    });

    test('doit passer à l\'année suivante une fois passé', () {
      expect(
        settings.nextAnniversary(DateTime(2026, 12, 13)),
        DateTime(2027, 12, 12),
      );
    });

    test('doit viser le premier anniversaire avant qu\'il ait eu lieu', () {
      expect(
        settings.nextAnniversary(DateTime(2023, 12, 12)),
        DateTime(2024, 12, 12),
      );
      expect(
        settings.nextAnniversary(DateTime(2020, 1, 1)),
        DateTime(2024, 12, 12),
      );
    });
  });

  group('nextMonthAnniversary', () {
    test('doit renvoyer celui de ce mois s\'il reste à venir', () {
      expect(
        settings.nextMonthAnniversary(DateTime(2026, 11, 12)),
        DateTime(2026, 11, 12),
      );
    });

    test('doit passer au mois suivant une fois passé', () {
      expect(
        settings.nextMonthAnniversary(DateTime(2026, 11, 13)),
        DateTime(2026, 12, 12),
      );
    });

    test('doit changer d\'année en décembre', () {
      expect(
        settings.nextMonthAnniversary(DateTime(2026, 12, 20)),
        DateTime(2027, 1, 12),
      );
    });

    test('doit viser le premier mois-anniversaire avant qu\'il ait eu lieu', () {
      expect(
        settings.nextMonthAnniversary(DateTime(2023, 12, 1)),
        DateTime(2024, 1, 12),
      );
    });
  });

  test('copyWith doit ne remplacer que les champs fournis', () {
    final copy = settings.copyWith(showMonthAnniversaries: true);

    expect(copy.showMonthAnniversaries, isTrue);
    expect(copy.relationshipStart, settings.relationshipStart);
    expect(copy.showAnniversary, settings.showAnniversary);
    expect(copy.anniversaryStyle, settings.anniversaryStyle);
  });
}
