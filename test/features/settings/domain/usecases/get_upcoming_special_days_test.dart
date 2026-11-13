// ============================================================================
// TEST UNITAIRE : GetUpcomingSpecialDays (use case, logique pure)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';
import 'package:amor_app/features/settings/domain/entities/upcoming_special_day.dart';
import 'package:amor_app/features/settings/domain/usecases/get_upcoming_special_days.dart';

void main() {
  const useCase = GetUpcomingSpecialDays();

  // --- Début de l'histoire : le 12 décembre 2023 ---
  final tSettings = CoupleSettingsEntity(
    relationshipStart: DateTime(2023, 12, 12),
  );

  test('ne doit rien annoncer tant que rien n\'est affiché', () {
    expect(useCase(tSettings, DateTime(2026, 11, 13)), isEmpty);
  });

  test('doit annoncer le prochain anniversaire', () {
    final result = useCase(
      tSettings.copyWith(showAnniversary: true),
      DateTime(2026, 11, 13),
    );

    expect(result, hasLength(1));
    expect(result.first.kind, UpcomingSpecialDayKind.anniversary);
    expect(result.first.date, DateTime(2026, 12, 12));
    expect(result.first.title, '3e anniversaire');
  });

  test('doit annoncer le prochain mois-anniversaire', () {
    final result = useCase(
      tSettings.copyWith(showMonthAnniversaries: true),
      DateTime(2026, 11, 13),
    );

    expect(result.single.kind, UpcomingSpecialDayKind.monthAnniversary);
    expect(result.single.title, '36 mois');
  });

  test('ne doit garder que l\'anniversaire s\'ils tombent le même jour', () {
    final result = useCase(
      tSettings.copyWith(showAnniversary: true, showMonthAnniversaries: true),
      DateTime(2026, 11, 13),
    );

    expect(result.single.kind, UpcomingSpecialDayKind.anniversary);
  });

  test('doit annoncer les deux, du plus proche au plus lointain', () {
    final result = useCase(
      tSettings.copyWith(showAnniversary: true, showMonthAnniversaries: true),
      DateTime(2026, 12, 13),
    );

    expect(result.map((day) => day.title), ['37 mois', '4e anniversaire']);
    expect(result.map((day) => day.date), [
      DateTime(2027, 1, 12),
      DateTime(2027, 12, 12),
    ]);
  });

  test('doit reprendre le style de chaque jour spécial', () {
    final settings = tSettings.copyWith(showMonthAnniversaries: true);

    final result = useCase(settings, DateTime(2026, 11, 13));

    expect(result.single.style, settings.monthAnniversaryStyle);
  });
}
