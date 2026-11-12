// ============================================================================
// CALENDAR VIEWMODEL
// ============================================================================
// Détient uniquement l'état d'affichage du calendrier (mois ciblé, jour
// sélectionné, format). Pas encore de données d'événements : elles seront
// branchées ici une fois les couches domain/data créées.

import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;

  bool isSelected(DateTime day) {
    return _selectedDay != null && isSameDay(_selectedDay, day);
  }

  // --- L'utilisateur tape sur un jour ---
  void selectDay(DateTime selected, DateTime focused) {
    if (isSameDay(_selectedDay, selected)) return;
    _selectedDay = selected;
    _focusedDay = focused;
    notifyListeners();
  }

  // --- L'utilisateur swipe vers un autre mois/semaine ---
  void changePage(DateTime focused) {
    // --- Pas de notifyListeners ici : table_calendar recommande de ne
    // --- mettre à jour la valeur que pour le prochain rebuild ---
    _focusedDay = focused;
  }

  // --- L'utilisateur change le format d'affichage (mois/2 semaines/semaine) ---
  void changeFormat(CalendarFormat format) {
    if (_calendarFormat == format) return;
    _calendarFormat = format;
    notifyListeners();
  }
}