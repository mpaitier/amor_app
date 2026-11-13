// ============================================================================
// USE CASE: GROUP EVENTS BY DAY
// ============================================================================
// Range les souvenirs par jour civil pour que le calendrier retrouve en une
// lecture ceux d'une date donnée. La clé est le jour à minuit, heure locale.

import '../../../timeline/domain/entities/timeline_event_entity.dart';

class GroupEventsByDay {
  const GroupEventsByDay();

  Map<DateTime, List<TimelineEventEntity>> call(
    List<TimelineEventEntity> events,
  ) {
    final grouped = <DateTime, List<TimelineEventEntity>>{};

    for (final event in events) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      grouped.putIfAbsent(day, () => []).add(event);
    }

    // --- Dans une même journée, le plus ancien en premier ---
    for (final dayEvents in grouped.values) {
      dayEvents.sort((a, b) => a.date.compareTo(b.date));
    }

    return grouped;
  }
}
