// ============================================================================
// CALENDAR SPECIAL DAY ENTITY
// ============================================================================
// Ce qu'affiche une case spéciale du calendrier, quelle que soit sa source :
// une date importante, l'anniversaire ou un mois-anniversaire.

import '../../../important_dates/domain/entities/important_date_entity.dart';

enum CalendarSpecialDayKind { importantDate, anniversary, monthAnniversary }

class CalendarSpecialDay {
  final CalendarSpecialDayKind kind;
  final String title;
  final String emoji;
  final int backgroundColor;
  final int borderColor;

  // --- La date importante d'origine, pour pouvoir la modifier. Null pour
  // --- un anniversaire, qui vient des réglages ---
  final ImportantDateEntity? importantDate;

  const CalendarSpecialDay({
    required this.kind,
    required this.title,
    required this.emoji,
    required this.backgroundColor,
    required this.borderColor,
    this.importantDate,
  });

  factory CalendarSpecialDay.fromImportantDate(ImportantDateEntity date) {
    return CalendarSpecialDay(
      kind: CalendarSpecialDayKind.importantDate,
      title: date.title,
      emoji: date.emoji,
      backgroundColor: date.backgroundColor,
      borderColor: date.borderColor,
      importantDate: date,
    );
  }
}
