// ============================================================================
// CALENDAR LABELS
// ============================================================================
// Libellés français du calendrier. Écrits en dur plutôt que tirés de intl :
// l'app n'existe qu'en français et les tests n'ont ainsi aucune locale à
// initialiser.

import '../../domain/entities/calendar_month.dart';

const List<String> calendarMonthNames = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

const List<String> calendarMonthShortNames = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

// --- Du lundi au dimanche ---
const List<String> calendarWeekdayInitials = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

// --- "Octobre 2026" ---
String formatMonthYear(CalendarMonth month) {
  return '${calendarMonthNames[month.month - 1]} ${month.year}';
}
