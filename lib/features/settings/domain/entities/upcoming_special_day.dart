// ============================================================================
// UPCOMING SPECIAL DAY ENTITY
// ============================================================================
// Prochaine occurrence d'un jour spécial tiré des réglages du couple, telle
// que le journal l'annonce.

import 'special_day_style.dart';

enum UpcomingSpecialDayKind { anniversary, monthAnniversary }

class UpcomingSpecialDay {
  final UpcomingSpecialDayKind kind;
  final DateTime date;
  final String title;
  final SpecialDayStyle style;

  const UpcomingSpecialDay({
    required this.kind,
    required this.date,
    required this.title,
    required this.style,
  });
}
