// ============================================================================
// CALENDAR LAYOUT (UI MODEL)
// ============================================================================
// Géométrie du calendrier défilant : taille des cases, hauteur de chaque mois
// et conversions entre position de défilement et mois affiché.
//
// La liste est inversée : l'index 0 est le mois le plus récent, posé en bas,
// et les index montent vers le passé. Toutes les distances sont donc
// mesurées depuis le bas du mois le plus récent.
//
// Ce n'est PAS une entité de domaine : elle manipule des pixels, donc elle
// vit dans la couche presentation (comme NavDestination ou ImageItem).

import 'dart:math' as math;
import '../../domain/entities/calendar_month.dart';

class CalendarLayout {
  // --- Marges et espacements, partagés avec l'en-tête des jours ---
  static const double horizontalPadding = 12;
  static const double cellGap = 6;
  static const double rowSidePadding = horizontalPadding - cellGap / 2;
  static const double rowGap = 6;

  // --- Bande au-dessus de chaque case, où monte le numéro d'un souvenir ---
  static const double dayNumberHeight = 14;

  // --- Hauteur du titre "Octobre 2026" glissé entre deux mois ---
  static const double monthTitleHeight = 44;

  // --- Espace libre sous le dernier mois, pour dégager le menu flottant ---
  static const double bottomInset = 88;

  // --- Nombre de lignes supposé pour un index hors de la liste ---
  static const int _fallbackWeekCount = 5;

  final double width;
  final CalendarMonth lastMonth;
  final int monthCount;
  final double cellSize;
  final double rowHeight;
  final List<int> _weekCounts;
  final List<double> _monthEnds;

  CalendarLayout._(
    this.width,
    this.lastMonth,
    this.monthCount,
    this.cellSize,
    this.rowHeight,
    this._weekCounts,
    this._monthEnds,
  );

  factory CalendarLayout({
    required double width,
    required CalendarMonth lastMonth,
    required int monthCount,
  }) {
    assert(monthCount > 0, 'le calendrier doit contenir au moins un mois');

    final cellSize = math.max(
      0.0,
      (width - 2 * horizontalPadding - 6 * cellGap) / 7,
    );
    final rowHeight = dayNumberHeight + cellSize + rowGap;

    // --- Hauteurs cumulées : _monthEnds[i] est le haut du mois i ---
    final weekCounts = <int>[];
    final monthEnds = <double>[];
    var total = 0.0;
    for (var index = 0; index < monthCount; index++) {
      final weekCount = lastMonth.addMonths(-index).weekCount;
      total += monthTitleHeight + weekCount * rowHeight;
      weekCounts.add(weekCount);
      monthEnds.add(total);
    }

    return CalendarLayout._(
      width,
      lastMonth,
      monthCount,
      cellSize,
      rowHeight,
      weekCounts,
      monthEnds,
    );
  }

  // --- Mois affiché à un index donné (0 = le plus récent) ---
  CalendarMonth monthAt(int index) => lastMonth.addMonths(-index);

  // --- Hauteur totale d'un mois : son titre puis ses lignes ---
  double monthExtent(int index) {
    final weekCount = (index >= 0 && index < monthCount)
        ? _weekCounts[index]
        : _fallbackWeekCount;
    return monthTitleHeight + weekCount * rowHeight;
  }

  // --- Index du mois qui touche le haut de la zone visible. C'est lui que
  // --- l'en-tête fixe doit afficher ---
  int topMonthIndex({
    required double scrollOffset,
    required double viewportHeight,
  }) {
    final topEdge = scrollOffset + viewportHeight - bottomInset;

    // --- Premier mois dont le haut est au niveau du bord ou au-dessus ---
    var low = 0;
    var high = monthCount - 1;
    while (low < high) {
      final middle = (low + high) ~/ 2;
      if (_monthEnds[middle] >= topEdge) {
        high = middle;
      } else {
        low = middle + 1;
      }
    }
    return low;
  }

  // --- Position de défilement qui amène la première ligne d'un mois juste
  // --- sous l'en-tête. Bornée, donc un mois trop récent reste en bas ---
  double scrollOffsetForMonth({
    required int index,
    required double viewportHeight,
    required double maxScrollExtent,
  }) {
    final safeIndex = math.min(math.max(index, 0), monthCount - 1);
    final target =
        _monthEnds[safeIndex] - monthTitleHeight - viewportHeight + bottomInset;
    final upperBound = math.max(0.0, maxScrollExtent);
    return math.min(math.max(target, 0.0), upperBound);
  }
}
