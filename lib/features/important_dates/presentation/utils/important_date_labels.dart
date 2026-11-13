// ============================================================================
// IMPORTANT DATE LABELS
// ============================================================================
// Textes dérivés d'une date importante. Fonctions pures, sans Flutter.

import '../../domain/entities/important_date_entity.dart';

// --- Nombre de jours entre aujourd'hui et un jour donné. Calcul en UTC
// --- pour qu'un changement d'heure ne fausse pas le compte ---
int _daysBetween(DateTime today, DateTime day) {
  return DateTime.utc(day.year, day.month, day.day)
      .difference(DateTime.utc(today.year, today.month, today.day))
      .inDays;
}

// --- "Dans 45 jours", "Demain", "Aujourd'hui", "Il y a 3 jours"... ---
String formatCountdown(DateTime occurrence, DateTime today) {
  final days = _daysBetween(today, occurrence);

  if (days == 0) return 'Aujourd\'hui';
  if (days == 1) return 'Demain';
  if (days == -1) return 'Hier';
  if (days > 0) return 'Dans $days jours';
  return 'Il y a ${-days} jours';
}

// --- Version courte pour la bannière : "45 J", "Jour J", ou "Passée"
// --- quand la date ne reviendra plus ---
String formatShortCountdown(DateTime? nextOccurrence, DateTime today) {
  if (nextOccurrence == null) return 'Passée';

  final days = _daysBetween(today, nextOccurrence);
  if (days < 0) return 'Passée';
  if (days == 0) return 'Jour J';
  return '$days J';
}

// --- "Tous les ans", "Tous les mois"... ---
String recurrenceLabel(ImportantDateRecurrence recurrence) {
  switch (recurrence) {
    case ImportantDateRecurrence.none:
      return 'Une seule fois';
    case ImportantDateRecurrence.weekly:
      return 'Toutes les semaines';
    case ImportantDateRecurrence.monthly:
      return 'Tous les mois';
    case ImportantDateRecurrence.yearly:
      return 'Tous les ans';
  }
}
