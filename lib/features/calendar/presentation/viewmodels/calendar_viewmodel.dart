// ============================================================================
// CALENDAR VIEWMODEL
// ============================================================================
// Détient l'état du calendrier : la plage de mois affichable, les souvenirs
// rangés par jour (temps réel) et le mois montré dans l'en-tête fixe.
// Ne connaît ni les pixels ni le défilement : la vue lui indique seulement
// quel mois se trouve en haut de l'écran.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../../../timeline/domain/usecases/watch_timeline_events.dart';
import '../../domain/entities/calendar_month.dart';
import '../../domain/usecases/group_events_by_day.dart';

class CalendarViewModel extends ChangeNotifier {
  // --- Profondeur de l'historique que l'on peut remonter en défilant ---
  static const int historyYears = 100;

  final WatchTimelineEvents _watchTimelineEvents;
  final GroupEventsByDay _groupEventsByDay;

  StreamSubscription<List<TimelineEventEntity>>? _subscription;

  // --- Bornes fixes, calculées à l'ouverture de l'écran ---
  final DateTime today;
  final CalendarMonth lastMonth;
  final CalendarMonth firstMonth;

  // --- State ---
  Map<DateTime, List<TimelineEventEntity>> _eventsByDay = const {};
  CalendarMonth _visibleMonth;
  String? _errorMessage;

  CalendarViewModel({
    required WatchTimelineEvents watchTimelineEvents,
    required GroupEventsByDay groupEventsByDay,
    DateTime? now,
  }) : this._(watchTimelineEvents, groupEventsByDay, now ?? DateTime.now());

  CalendarViewModel._(
    this._watchTimelineEvents,
    this._groupEventsByDay,
    DateTime now,
  )   : today = DateTime(now.year, now.month, now.day),
        lastMonth = CalendarMonth.fromDate(now),
        firstMonth = CalendarMonth(now.year - historyYears, 1),
        _visibleMonth = CalendarMonth.fromDate(now) {
    _listenToEvents();
  }

  // --- Getters ---
  CalendarMonth get visibleMonth => _visibleMonth;
  String? get errorMessage => _errorMessage;

  // --- Nombre de mois entre le plus ancien et le mois en cours, inclus ---
  int get monthCount => firstMonth.monthsUntil(lastMonth) + 1;

  // --- Mois à un index donné : 0 est le mois en cours, puis on remonte ---
  CalendarMonth monthAt(int index) {
    return lastMonth.addMonths(-_clampIndex(index));
  }

  // --- Index d'un mois, ramené dans la plage affichable ---
  int indexOf(CalendarMonth month) {
    return _clampIndex(month.monthsUntil(lastMonth));
  }

  // --- Souvenirs d'un jour donné, du plus ancien au plus récent ---
  List<TimelineEventEntity> eventsOn(DateTime day) {
    return _eventsByDay[DateTime(day.year, day.month, day.day)] ?? const [];
  }

  // --- La vue signale quel mois touche le haut de l'écran ---
  void showMonthAt(int index) {
    final month = monthAt(index);
    if (month == _visibleMonth) return;
    _visibleMonth = month;
    notifyListeners();
  }

  // --- Abonnement au flux temps réel des souvenirs ---
  void _listenToEvents() {
    _subscription = _watchTimelineEvents().listen((events) {
      _eventsByDay = _groupEventsByDay(events);
      _errorMessage = null;
      notifyListeners();
    }, onError: (Object error) {
      _errorMessage = 'Impossible de charger les souvenirs : $error';
      notifyListeners();
    });
  }

  int _clampIndex(int index) {
    if (index < 0) return 0;
    if (index >= monthCount) return monthCount - 1;
    return index;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
