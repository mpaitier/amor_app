// ============================================================================
// IMPORTANT DATE ENTITY
// ============================================================================
// Une date qui compte pour le couple (anniversaire, voyage à venir...).
// Modèle de domaine pur, indépendant de Firestore et de Flutter : les
// couleurs sont de simples entiers ARGB.

class ImportantDateEntity {
  // --- Couleurs appliquées quand rien n'a été choisi ---
  static const int defaultBackgroundColor = 0xFFFFD9E2;
  static const int defaultBorderColor = 0xFF703348;

  final String id;
  final String title;

  // --- Jour de la date. Pour une date répétée, c'est la première fois ---
  final DateTime date;

  final String emoji;
  final bool repeatsYearly;
  final int backgroundColor;
  final int borderColor;

  const ImportantDateEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.emoji,
    required this.repeatsYearly,
    this.backgroundColor = defaultBackgroundColor,
    this.borderColor = defaultBorderColor,
  });

  // --- Copy with modifications ---
  ImportantDateEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? emoji,
    bool? repeatsYearly,
    int? backgroundColor,
    int? borderColor,
  }) {
    return ImportantDateEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      emoji: emoji ?? this.emoji,
      repeatsYearly: repeatsYearly ?? this.repeatsYearly,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  // --- La date tombe-t-elle ce jour-là ? Une date répétée revient chaque
  // --- année à partir de sa première fois, jamais avant ---
  bool occursOn(DateTime day) {
    if (!repeatsYearly) {
      return day.year == date.year &&
          day.month == date.month &&
          day.day == date.day;
    }

    if (day.year < date.year) return false;
    final occurrence = occurrenceInYear(day.year);
    return day.month == occurrence.month && day.day == occurrence.day;
  }

  // --- Jour où tombe la date une année donnée. Un 29 février est ramené
  // --- au 28 les années qui n'en ont pas ---
  DateTime occurrenceInYear(int year) {
    final lastDayOfMonth = DateTime(year, date.month + 1, 0).day;
    final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
    return DateTime(year, date.month, day);
  }

  // --- Prochaine fois où la date tombe, à partir de `from` inclus.
  // --- Vaut null pour une date ponctuelle déjà passée ---
  DateTime? nextOccurrence(DateTime from) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final firstDay = DateTime(date.year, date.month, date.day);

    if (!firstDay.isBefore(fromDay)) return firstDay;
    if (!repeatsYearly) return null;

    final thisYear = occurrenceInYear(fromDay.year);
    if (!thisYear.isBefore(fromDay)) return thisYear;
    return occurrenceInYear(fromDay.year + 1);
  }
}
