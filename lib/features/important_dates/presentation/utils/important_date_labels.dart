// ============================================================================
// IMPORTANT DATE LABELS
// ============================================================================
// Textes dérivés d'une date importante. Fonctions pures, sans Flutter.

// --- "Dans 45 jours", "Demain", "Aujourd'hui", "Il y a 3 jours"... ---
String formatCountdown(DateTime occurrence, DateTime today) {
  // --- Calcul en UTC pour qu'un changement d'heure ne fausse pas le compte ---
  final days = DateTime.utc(occurrence.year, occurrence.month, occurrence.day)
      .difference(DateTime.utc(today.year, today.month, today.day))
      .inDays;

  if (days == 0) return 'Aujourd\'hui';
  if (days == 1) return 'Demain';
  if (days == -1) return 'Hier';
  if (days > 0) return 'Dans $days jours';
  return 'Il y a ${-days} jours';
}
