// ============================================================================
// USE CASE: GET UPCOMING SPECIAL DAYS
// ============================================================================
// Prochains anniversaire et mois-anniversaire affichés, du plus proche au
// plus lointain. S'ils tombent le même jour, seul l'anniversaire reste.

import '../entities/couple_settings_entity.dart';
import '../entities/upcoming_special_day.dart';
import '../utils/anniversary_titles.dart';

class GetUpcomingSpecialDays {
  const GetUpcomingSpecialDays();

  List<UpcomingSpecialDay> call(CoupleSettingsEntity settings, DateTime today) {
    final upcoming = <UpcomingSpecialDay>[];
    DateTime? anniversaryDate;

    if (settings.showAnniversary) {
      final date = settings.nextAnniversary(today);
      anniversaryDate = date;
      upcoming.add(
        UpcomingSpecialDay(
          kind: UpcomingSpecialDayKind.anniversary,
          date: date,
          title: anniversaryTitle(settings.anniversaryNumberOn(date) ?? 1),
          style: settings.anniversaryStyle,
        ),
      );
    }

    if (settings.showMonthAnniversaries) {
      final date = settings.nextMonthAnniversary(today);
      if (date != anniversaryDate) {
        upcoming.add(
          UpcomingSpecialDay(
            kind: UpcomingSpecialDayKind.monthAnniversary,
            date: date,
            title: monthAnniversaryTitle(
              settings.monthAnniversaryNumberOn(date) ?? 1,
            ),
            style: settings.monthAnniversaryStyle,
          ),
        );
      }
    }

    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }
}
