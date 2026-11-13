// ============================================================================
// RECURRENCE RULE (UI MODEL)
// ============================================================================
// Ce que renvoie la boîte de dialogue de répétition : une fréquence et,
// éventuellement, un nombre de fois après lequel la date s'arrête.

import '../../domain/entities/important_date_entity.dart';

class RecurrenceRule {
  final ImportantDateRecurrence recurrence;
  final int? occurrenceLimit;

  const RecurrenceRule({required this.recurrence, this.occurrenceLimit});
}
