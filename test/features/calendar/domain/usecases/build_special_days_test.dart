// ============================================================================
// TEST UNITAIRE : BuildSpecialDays (use case, logique pure)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/calendar/domain/entities/calendar_special_day.dart';
import 'package:amor_app/features/calendar/domain/usecases/build_special_days.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';

void main() {
  const useCase = BuildSpecialDays();

  // --- Début de l'histoire : le 12 décembre 2023 ---
  final tSettings = CoupleSettingsEntity(
    relationshipStart: DateTime(2023, 12, 12),
  );

  final tDate = ImportantDateEntity(
    id: 'd1',
    title: 'Noël',
    date: DateTime(2026, 12, 12),
    emoji: '🎄',
    recurrence: ImportantDateRecurrence.none,
  );

  test('doit renvoyer les dates importantes du jour sans réglages', () {
    final result = useCase(day: DateTime(2026, 12, 12), importantDates: [tDate]);

    expect(result, hasLength(1));
    expect(result.first.kind, CalendarSpecialDayKind.importantDate);
    expect(result.first.importantDate, tDate);
  });

  test('doit ignorer les anniversaires tant qu\'ils ne sont pas affichés', () {
    final result = useCase(
      day: DateTime(2026, 12, 12),
      importantDates: const [],
      settings: tSettings,
    );

    expect(result, isEmpty);
  });

  test('doit créer l\'anniversaire avec son style', () {
    final settings = tSettings.copyWith(showAnniversary: true);

    final result = useCase(
      day: DateTime(2024, 12, 12),
      importantDates: const [],
      settings: settings,
    );

    expect(result, hasLength(1));
    expect(result.first.kind, CalendarSpecialDayKind.anniversary);
    expect(result.first.title, '1er anniversaire');
    expect(result.first.emoji, settings.anniversaryStyle.emoji);
    expect(result.first.importantDate, isNull);
  });

  test('doit créer le mois-anniversaire avec son style', () {
    final settings = tSettings.copyWith(showMonthAnniversaries: true);

    final result = useCase(
      day: DateTime(2026, 11, 12),
      importantDates: const [],
      settings: settings,
    );

    expect(result.single.kind, CalendarSpecialDayKind.monthAnniversary);
    expect(result.single.title, '35 mois');
    expect(
      result.single.borderColor,
      settings.monthAnniversaryStyle.borderColor,
    );
  });

  test('doit laisser l\'anniversaire couvrir le mois-anniversaire du même jour',
      () {
    final settings = tSettings.copyWith(
      showAnniversary: true,
      showMonthAnniversaries: true,
    );

    final result = useCase(
      day: DateTime(2026, 12, 12),
      importantDates: const [],
      settings: settings,
    );

    expect(result.single.title, '3e anniversaire');
  });

  test('doit garder le mois-anniversaire si l\'anniversaire est masqué', () {
    final settings = tSettings.copyWith(showMonthAnniversaries: true);

    final result = useCase(
      day: DateTime(2026, 12, 12),
      importantDates: const [],
      settings: settings,
    );

    expect(result.single.title, '36 mois');
  });

  test('doit placer l\'anniversaire avant les dates importantes', () {
    final result = useCase(
      day: DateTime(2026, 12, 12),
      importantDates: [tDate],
      settings: tSettings.copyWith(showAnniversary: true),
    );

    expect(result.map((day) => day.kind), [
      CalendarSpecialDayKind.anniversary,
      CalendarSpecialDayKind.importantDate,
    ]);
  });
}
