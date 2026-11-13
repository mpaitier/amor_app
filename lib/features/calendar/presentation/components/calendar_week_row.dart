// ============================================================================
// CALENDAR WEEK ROW
// ============================================================================
// Une semaine du lundi au dimanche. Choisit pour chaque jour la bonne case :
// vide hors du mois, numéro seul, couverture d'un souvenir, ou jour spécial
// (date importante, anniversaire, mois-anniversaire).

import 'package:flutter/material.dart';
import '../../domain/entities/calendar_special_day.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../models/calendar_layout.dart';
import 'calendar_day_cell.dart';
import 'calendar_memory_cell.dart';
import 'calendar_special_day_cell.dart';

class CalendarWeekRow extends StatelessWidget {
  final List<DateTime?> days;
  final double rowHeight;
  final DateTime today;
  final List<TimelineEventEntity> Function(DateTime day) eventsOn;
  final List<CalendarSpecialDay> Function(DateTime day) specialDaysOn;
  final void Function(DateTime day) onDayTap;

  const CalendarWeekRow({
    super.key,
    required this.days,
    required this.rowHeight,
    required this.today,
    required this.eventsOn,
    required this.specialDaysOn,
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
    final specialDays = specialDaysOn(day);

    if (events.isEmpty && specialDays.isEmpty) {
      return CalendarDayCell(day: day.day, isToday: day == today);
    }

    if (events.isEmpty) {
      return CalendarSpecialDayCell(
        day: day.day,
        specialDay: specialDays.first,
        onTap: () => onDayTap(day),
      );
    }

    // --- La couverture est la première image du premier souvenir du jour.
    // --- Un jour spécial le même jour y ajoute sa bordure et son emoji ---
    final images = events.first.imagesList;
    final specialDay = specialDays.isNotEmpty ? specialDays.first : null;

    return CalendarMemoryCell(
      day: day.day,
      coverUrl: images.isNotEmpty ? images.first : '',
      borderColor: specialDay?.borderColor,
      badgeEmoji: specialDay?.emoji,
      onTap: () => onDayTap(day),
    );
  }
}
