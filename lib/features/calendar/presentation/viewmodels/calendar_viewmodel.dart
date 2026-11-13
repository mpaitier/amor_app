// ============================================================================
// CALENDAR VIEWMODEL
// ============================================================================
// Détient l'état du calendrier : la plage de mois affichable, les souvenirs
// rangés par jour, les dates importantes (tous deux en temps réel) et le
// mois montré dans l'en-tête fixe.
// Ne connaît ni les pixels ni le défilement : la vue lui indique seulement
// quel mois se trouve en haut de l'écran.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../important_dates/domain/entities/important_date_entity.dart';
import '../../../important_dates/domain/usecases/delete_important_date.dart';
import '../../../important_dates/domain/usecases/watch_important_dates.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../../../timeline/domain/usecases/watch_timeline_events.dart';
import '../../domain/entities/calendar_month.dart';
import '../../domain/usecases/group_events_by_day.dart';

class CalendarViewModel extends ChangeNotifier {
  // --- Profondeur de l'historique que l'on peut remonter en défilant ---
  static const int historyYears = 100;

  final WatchTimelineEvents _watchTimelineEvents;
  final WatchImportantDates _watchImportantDates;
  final DeleteImportantDate _deleteImportantDate;
  final GroupEventsByDay _groupEventsByDay;

  StreamSubscription<List<TimelineEventEntity>>? _eventsSubscription;
  StreamSubscription<List<ImportantDateEntity>>? _importantDatesSubscription;

  // --- Repères fixes, calculés à l'ouverture de l'écran ---
  final DateTime today;
  final CalendarMonth currentMonth;
  final CalendarMonth firstMonth;

  // --- State ---
  Map<DateTime, List<TimelineEventEntity>> _eventsByDay = const {};
  List<ImportantDateEntity> _importantDates = const [];
  CalendarMonth _lastMonth;
  CalendarMonth _visibleMonth;
  String? _errorMessage;

  CalendarViewModel({
    required WatchTimelineEvents watchTimelineEvents,
    required WatchImportantDates watchImportantDates,
    required DeleteImportantDate deleteImportantDate,
    required GroupEventsByDay groupEventsByDay,
    DateTime? now,
  }) : this._(
          watchTimelineEvents,
          watchImportantDates,
          deleteImportantDate,
          groupEventsByDay,
          now ?? DateTime.now(),
        );

  CalendarViewModel._(
    this._watchTimelineEvents,
    this._watchImportantDates,
    this._deleteImportantDate,
    this._groupEventsByDay,
    DateTime now,
  )   : today = DateTime(now.year, now.month, now.day),
        currentMonth = CalendarMonth.fromDate(now),
        firstMonth = CalendarMonth(now.year - historyYears, 1),
        _lastMonth = CalendarMonth.fromDate(now),
        _visibleMonth = CalendarMonth.fromDate(now) {
    _listenToEvents();
    _listenToImportantDates();
  }

  // --- Getters ---
  CalendarMonth get visibleMonth => _visibleMonth;
  String? get errorMessage => _errorMessage;

  // --- Dernier mois du calendrier : le mois en cours, repoussé jusqu'à la
  // --- date importante à venir la plus lointaine s'il y en a une ---
  CalendarMonth get lastMonth => _lastMonth;

  // --- Nombre de mois entre le plus ancien et le dernier, inclus ---
  int get monthCount => firstMonth.monthsUntil(_lastMonth) + 1;

  // --- Index du mois en cours : 0 tant qu'aucune date n'est à venir ---
  int get currentMonthIndex => currentMonth.monthsUntil(_lastMonth);

  // --- Mois à un index donné : 0 est le dernier mois, puis on remonte ---
  CalendarMonth monthAt(int index) {
    return _lastMonth.addMonths(-_clampIndex(index));
  }

  // --- Index d'un mois, ramené dans la plage affichable ---
  int indexOf(CalendarMonth month) {
    return _clampIndex(month.monthsUntil(_lastMonth));
  }

  // --- Souvenirs d'un jour donné, du plus ancien au plus récent ---
  List<TimelineEventEntity> eventsOn(DateTime day) {
    return _eventsByDay[DateTime(day.year, day.month, day.day)] ?? const [];
  }

  // --- Dates importantes qui tombent un jour donné, répétitions comprises ---
  List<ImportantDateEntity> importantDatesOn(DateTime day) {
    return [
      for (final date in _importantDates)
        if (date.occursOn(day)) date,
    ];
  }

  // --- La vue signale quel mois touche le haut de l'écran ---
  void showMonth(CalendarMonth month) {
    if (month == _visibleMonth) return;
    _visibleMonth = month;
    notifyListeners();
  }

  // --- Supprime une date importante, renvoie true en cas de succès ---
  Future<bool> deleteImportantDate(String dateId) async {
    try {
      await _deleteImportantDate(dateId);
      return true;
    } catch (e) {
      _errorMessage = 'Impossible de supprimer cette date : $e';
      notifyListeners();
      return false;
    }
  }

  // --- Abonnement au flux temps réel des souvenirs ---
  void _listenToEvents() {
    _eventsSubscription = _watchTimelineEvents().listen((events) {
      _eventsByDay = _groupEventsByDay(events);
      notifyListeners();
    }, onError: (Object error) {
      _errorMessage = 'Impossible de charger les souvenirs : $error';
      notifyListeners();
    });
  }

  // --- Abonnement au flux temps réel des dates importantes. Chaque
  // --- émission peut déplacer la fin du calendrier ---
  void _listenToImportantDates() {
    _importantDatesSubscription = _watchImportantDates().listen((dates) {
      _importantDates = dates;
      _lastMonth = _computeLastMonth();
      notifyListeners();
    }, onError: (Object error) {
      _errorMessage = 'Impossible de charger les dates importantes : $error';
      notifyListeners();
    });
  }

  // --- Mois de la prochaine occurrence la plus lointaine, sans jamais
  // --- descendre sous le mois en cours ---
  CalendarMonth _computeLastMonth() {
    var last = currentMonth;
    for (final date in _importantDates) {
      final next = date.nextOccurrence(today);
      if (next == null) continue;

      final month = CalendarMonth.fromDate(next);
      if (month.isAfter(last)) last = month;
    }
    return last;
  }

  int _clampIndex(int index) {
    if (index < 0) return 0;
    if (index >= monthCount) return monthCount - 1;
    return index;
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _importantDatesSubscription?.cancel();
    super.dispose();
  }
}
