// ============================================================================
// USE CASE: BUILD SPECIAL DAYS
// ============================================================================
// Rassemble les cases spéciales d'un jour : d'abord l'anniversaire ou le
// mois-anniversaire tirés des réglages, puis les dates importantes.

import '../../../important_dates/domain/entities/important_date_entity.dart';
import '../../../settings/domain/entities/couple_settings_entity.dart';
import '../../../settings/domain/utils/anniversary_titles.dart';
import '../entities/calendar_special_day.dart';

class BuildSpecialDays {
  const BuildSpecialDays();

  List<CalendarSpecialDay> call({
    required DateTime day,
    required List<ImportantDateEntity> importantDates,
    CoupleSettingsEntity? settings,
  }) {
    return [
      ..._anniversaries(day, settings),
      for (final date in importantDates)
        if (date.occursOn(day)) CalendarSpecialDay.fromImportantDate(date),
    ];
  }

  List<CalendarSpecialDay> _anniversaries(
    DateTime day,
    CoupleSettingsEntity? settings,
  ) {
    if (settings == null) return const [];

    if (settings.showAnniversary) {
      final years = settings.anniversaryNumberOn(day);
      if (years != null) {
        final style = settings.anniversaryStyle;
        return [
          CalendarSpecialDay(
            kind: CalendarSpecialDayKind.anniversary,
            title: anniversaryTitle(years),
            emoji: style.emoji,
            backgroundColor: style.backgroundColor,
            borderColor: style.borderColor,
          ),
        ];
      }
    }

    // --- L'anniversaire affiché couvre déjà les mois multiples de 12 ---
    if (settings.showMonthAnniversaries) {
      final months = settings.monthAnniversaryNumberOn(day);
      final coveredByAnniversary =
          settings.showAnniversary && months != null && months % 12 == 0;
      if (months != null && !coveredByAnniversary) {
        final style = settings.monthAnniversaryStyle;
        return [
          CalendarSpecialDay(
            kind: CalendarSpecialDayKind.monthAnniversary,
            title: monthAnniversaryTitle(months),
            emoji: style.emoji,
            backgroundColor: style.backgroundColor,
            borderColor: style.borderColor,
          ),
        ];
      }
    }

    return const [];
  }
}
