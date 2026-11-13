// ============================================================================
// IMPORTANT DATE ENTITY
// ============================================================================
// Une date qui compte pour le couple (anniversaire, voyage à venir...).
// Modèle de domaine pur, indépendant de Firestore et de Flutter : les
// couleurs sont de simples entiers ARGB.

// --- Fréquence à laquelle une date revient ---
enum ImportantDateRecurrence { none, weekly, monthly, yearly }

class ImportantDateEntity {
  // --- Couleurs appliquées quand rien n'a été choisi ---
  static const int defaultBackgroundColor = 0xFFFFD9E2;
  static const int defaultBorderColor = 0xFF703348;

  final String id;
  final String title;

  // --- Jour de la date. Pour une date répétée, c'est la première fois ---
  final DateTime date;

  final String emoji;
  final ImportantDateRecurrence recurrence;
  final int backgroundColor;
  final int borderColor;

  const ImportantDateEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.emoji,
    required this.recurrence,
    this.backgroundColor = defaultBackgroundColor,
    this.borderColor = defaultBorderColor,
  });

  bool get repeats => recurrence != ImportantDateRecurrence.none;

  // --- Copy with modifications ---
  ImportantDateEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? emoji,
    ImportantDateRecurrence? recurrence,
    int? backgroundColor,
    int? borderColor,
  }) {
    return ImportantDateEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      emoji: emoji ?? this.emoji,
      recurrence: recurrence ?? this.recurrence,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  // --- Le jour de la date, sans heure ---
  DateTime get _firstDay => DateTime(date.year, date.month, date.day);

  // --- La date tombe-t-elle ce jour-là ? Une date répétée revient à partir
  // --- de sa première fois, jamais avant ---
  bool occursOn(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    final first = _firstDay;
    if (target.isBefore(first)) return false;

    switch (recurrence) {
      case ImportantDateRecurrence.none:
        return target == first;
      case ImportantDateRecurrence.weekly:
        return target.weekday == first.weekday;
      case ImportantDateRecurrence.monthly:
        return target == occurrenceInMonth(target.year, target.month);
      case ImportantDateRecurrence.yearly:
        return target == occurrenceInYear(target.year);
    }
  }

  // --- Jour où tombe la date un mois donné. Un 31 est ramené au dernier
  // --- jour des mois plus courts ---
  DateTime occurrenceInMonth(int year, int month) {
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
    return DateTime(year, month, day);
  }

  // --- Jour où tombe la date une année donnée. Un 29 février est ramené
  // --- au 28 les années qui n'en ont pas ---
  DateTime occurrenceInYear(int year) => occurrenceInMonth(year, date.month);

  // --- Prochaine fois où la date tombe, à partir de `from` inclus.
  // --- Vaut null pour une date ponctuelle déjà passée ---
  DateTime? nextOccurrence(DateTime from) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final first = _firstDay;
    if (!first.isBefore(fromDay)) return first;

    switch (recurrence) {
      case ImportantDateRecurrence.none:
        return null;

      case ImportantDateRecurrence.weekly:
        final daysAhead = (first.weekday - fromDay.weekday) % 7;
        return DateTime(fromDay.year, fromDay.month, fromDay.day + daysAhead);

      case ImportantDateRecurrence.monthly:
        final thisMonth = occurrenceInMonth(fromDay.year, fromDay.month);
        if (!thisMonth.isBefore(fromDay)) return thisMonth;
        final nextMonth = DateTime(fromDay.year, fromDay.month + 1, 1);
        return occurrenceInMonth(nextMonth.year, nextMonth.month);

      case ImportantDateRecurrence.yearly:
        final thisYear = occurrenceInYear(fromDay.year);
        if (!thisYear.isBefore(fromDay)) return thisYear;
        return occurrenceInYear(fromDay.year + 1);
    }
  }
}
