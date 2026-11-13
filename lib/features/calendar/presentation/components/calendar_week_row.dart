// ============================================================================
// CALENDAR WEEK ROW
// ============================================================================
// Une semaine du lundi au dimanche. Choisit pour chaque jour la bonne case :
// vide hors du mois, numéro seul, couverture d'un souvenir, ou date
// importante.

import 'package:flutter/material.dart';
import '../../../important_dates/domain/entities/important_date_entity.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../models/calendar_layout.dart';
import 'calendar_day_cell.dart';
import 'calendar_important_date_cell.dart';
import 'calendar_memory_cell.dart';

class CalendarWeekRow extends StatelessWidget {
  final List<DateTime?> days;
  final double rowHeight;
  final DateTime today;
  final List<TimelineEventEntity> Function(DateTime day) eventsOn;
  final List<ImportantDateEntity> Function(DateTime day) importantDatesOn;
  final void Function(DateTime day) onDayTap;

  const CalendarWeekRow({
    super.key,
    required this.days,
    required this.rowHeight,
    required this.today,
    required this.eventsOn,
    required this.importantDatesOn,
    required this.onDayTap,
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
    final importantDates = importantDatesOn(day);

    if (events.isEmpty && importantDates.isEmpty) {
      return CalendarDayCell(day: day.day, isToday: day == today);
    }

    if (events.isEmpty) {
      return CalendarImportantDateCell(
        day: day.day,
        date: importantDates.first,
        onTap: () => onDayTap(day),
      );
    }

    // --- La couverture est la première image du premier souvenir du jour.
    // --- Une date importante le même jour y ajoute sa bordure et son emoji ---
    final images = events.first.imagesList;
    final importantDate =
        importantDates.isNotEmpty ? importantDates.first : null;

    return CalendarMemoryCell(
      day: day.day,
      coverUrl: images.isNotEmpty ? images.first : '',
      borderColor: importantDate?.borderColor,
      badgeEmoji: importantDate?.emoji,
      onTap: () => onDayTap(day),
    );
  }
}
