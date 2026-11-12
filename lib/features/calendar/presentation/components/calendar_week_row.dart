// ============================================================================
// CALENDAR WEEK ROW
// ============================================================================
// Une semaine du lundi au dimanche. Choisit pour chaque jour la bonne case :
// vide hors du mois, numéro seul, ou couverture s'il y a un souvenir.

import 'package:flutter/material.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../models/calendar_layout.dart';
import 'calendar_day_cell.dart';
import 'calendar_memory_cell.dart';

class CalendarWeekRow extends StatelessWidget {
  final List<DateTime?> days;
  final double rowHeight;
  final DateTime today;
  final List<TimelineEventEntity> Function(DateTime day) eventsOn;
  final void Function(List<TimelineEventEntity> events) onEventsTap;

  const CalendarWeekRow({
    super.key,
    required this.days,
    required this.rowHeight,
    required this.today,
    required this.eventsOn,
    required this.onEventsTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: Padding(
        padding: const EdgeInsets.only(
          left: CalendarLayout.rowSidePadding,
          right: CalendarLayout.rowSidePadding,
          bottom: CalendarLayout.rowGap,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final day in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CalendarLayout.cellGap / 2,
                  ),
                  child: _buildCell(day),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(DateTime? day) {
    // --- Case hors du mois ---
    if (day == null) return const SizedBox.shrink();

    final events = eventsOn(day);

    if (events.isEmpty) {
      return CalendarDayCell(day: day.day, isToday: day == today);
    }

    // --- La couverture est la première image du premier souvenir du jour ---
    final images = events.first.imagesList;
    return CalendarMemoryCell(
      day: day.day,
      coverUrl: images.isNotEmpty ? images.first : '',
      onTap: () => onEventsTap(events),
    );
  }
}
