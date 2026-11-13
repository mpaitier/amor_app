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

  // --- Nombre de fois où la date revient, la première comprise. Null :
  // --- sans fin. Ignoré pour une date ponctuelle ---
  final int? occurrenceLimit;

  final int backgroundColor;
  final int borderColor;

  // --- GIF tiré au hasard à la création ---
  final String gifUrl;

  const ImportantDateEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.emoji,
    required this.recurrence,
    this.occurrenceLimit,
    this.backgroundColor = defaultBackgroundColor,
    this.borderColor = defaultBorderColor,
    this.gifUrl = '',
  });

  bool get repeats => recurrence != ImportantDateRecurrence.none;

  // --- Copy with modifications. La limite se remplace toujours, pour
  // --- pouvoir la remettre à null ---
  ImportantDateEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? emoji,
    ImportantDateRecurrence? recurrence,
    int? Function()? occurrenceLimit,
    int? backgroundColor,
    int? borderColor,
    String? gifUrl,
  }) {
    return ImportantDateEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      emoji: emoji ?? this.emoji,
      recurrence: recurrence ?? this.recurrence,
      occurrenceLimit:
          occurrenceLimit != null ? occurrenceLimit() : this.occurrenceLimit,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      gifUrl: gifUrl ?? this.gifUrl,
    );
  }

  // --- Le jour de la date, sans heure ---
  DateTime get _firstDay => DateTime(date.year, date.month, date.day);

  // --- Rang d'un jour d'occurrence : 0 pour la première fois, 1 pour la
  // --- suivante... Suppose que le jour est bien une occurrence ---
  int _occurrenceIndex(DateTime occurrence) {
    final first = _firstDay;
    switch (recurrence) {
      case ImportantDateRecurrence.none:
        return 0;
      case ImportantDateRecurrence.weekly:
        final days = DateTime.utc(
          occurrence.year,
          occurrence.month,
          occurrence.day,
        ).difference(DateTime.utc(first.year, first.month, first.day)).inDays;
        return days ~/ 7;
      case ImportantDateRecurrence.monthly:
        return (occurrence.year - first.year) * 12 +
            (occurrence.month - first.month);
      case ImportantDateRecurrence.yearly:
        return occurrence.year - first.year;
    }
  }

  // --- L'occurrence fait-elle partie des fois prévues ? ---
  bool _isWithinLimit(DateTime occurrence) {
    final limit = occurrenceLimit;
    if (limit == null || !repeats) return true;
    return _occurrenceIndex(occurrence) < limit;
  }

  // --- La date tombe-t-elle ce jour-là ? Une date répétée revient à partir
  // --- de sa première fois, jamais avant, et s'arrête à sa limite ---
  bool occursOn(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    if (target.isBefore(_firstDay)) return false;
    return _matches(target) && _isWithinLimit(target);
  }

  // --- Le jour tombe-t-il sur la fréquence, sans tenir compte de la limite ---
  bool _matches(DateTime target) {
    final first = _firstDay;
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
  // --- Vaut null si elle ne reviendra plus ---
  DateTime? nextOccurrence(DateTime from) {
    final candidate = _nextMatch(from);
    if (candidate == null || !_isWithinLimit(candidate)) return null;
    return candidate;
  }

  // --- Prochain jour sur la fréquence, sans tenir compte de la limite ---
  DateTime? _nextMatch(DateTime from) {
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
