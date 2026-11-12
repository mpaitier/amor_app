// ============================================================================
// CALENDAR MONTH ENTITY
// ============================================================================
// Un mois civil (année + mois), sans jour ni heure. Modèle de domaine pur,
// sans dépendance à Flutter. Les semaines commencent le lundi.

class CalendarMonth implements Comparable<CalendarMonth> {
  final int year;
  final int month;

  const CalendarMonth(this.year, this.month)
      : assert(month >= 1 && month <= 12, 'month doit être compris entre 1 et 12');

  factory CalendarMonth.fromDate(DateTime date) {
    return CalendarMonth(date.year, date.month);
  }

  // --- Rang du mois depuis l'an 0, utilisé pour l'arithmétique ---
  int get _serial => year * 12 + (month - 1);

  // --- Mois situé `delta` mois plus tard (ou plus tôt si négatif) ---
  CalendarMonth addMonths(int delta) {
    final serial = _serial + delta;
    return CalendarMonth(serial ~/ 12, serial % 12 + 1);
  }

  // --- Nombre de mois à ajouter pour atteindre `other` ---
  int monthsUntil(CalendarMonth other) => other._serial - _serial;

  // --- Nombre de jours du mois (le jour 0 du mois suivant est le dernier) ---
  int get dayCount => DateTime(year, month + 1, 0).day;

  // --- Cases vides avant le 1er, pour une semaine qui commence le lundi ---
  int get leadingEmptyDays => DateTime(year, month, 1).weekday - DateTime.monday;

  // --- Nombre de lignes nécessaires pour afficher le mois ---
  int get weekCount => ((leadingEmptyDays + dayCount) / 7).ceil();

  // --- Semaines du mois, du lundi au dimanche. Une case hors du mois
  // --- vaut null ---
  List<List<DateTime?>> get weeks {
    final cells = <DateTime?>[
      for (var i = 0; i < leadingEmptyDays; i++) null,
      for (var day = 1; day <= dayCount; day++) DateTime(year, month, day),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return [
      for (var start = 0; start < cells.length; start += 7)
        cells.sublist(start, start + 7),
    ];
  }

  bool isBefore(CalendarMonth other) => compareTo(other) < 0;

  bool isAfter(CalendarMonth other) => compareTo(other) > 0;

  @override
  int compareTo(CalendarMonth other) => _serial.compareTo(other._serial);

  @override
  bool operator ==(Object other) {
    return other is CalendarMonth && other.year == year && other.month == month;
  }

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'CalendarMonth($year-$month)';
}
