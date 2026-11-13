// ============================================================================
// CALENDAR MONTH LIST
// ============================================================================
// Le "parchemin" : tous les mois à la suite dans une seule liste défilante.
// La liste est inversée, donc son index 0 est le dernier mois, posé en bas,
// et l'on remonte vers le passé. Chaque mois a une hauteur connue d'avance
// (CalendarLayout), ce qui permet de sauter à un mois lointain sans
// construire tous ceux qui le séparent de l'écran.

import 'package:flutter/material.dart';
import '../../../important_dates/domain/entities/important_date_entity.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../../domain/entities/calendar_month.dart';
import '../models/calendar_layout.dart';
import 'calendar_month_section.dart';

class CalendarMonthList extends StatelessWidget {
  final ScrollController controller;
  final CalendarLayout layout;
  final CalendarMonth visibleMonth;
  final DateTime today;
  final List<TimelineEventEntity> Function(DateTime day) eventsOn;
  final List<ImportantDateEntity> Function(DateTime day) importantDatesOn;
  final void Function(DateTime day) onDayTap;

  const CalendarMonthList({
    super.key,
    required this.controller,
    required this.layout,
    required this.visibleMonth,
    required this.today,
    required this.eventsOn,
    required this.importantDatesOn,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: const EdgeInsets.only(bottom: CalendarLayout.bottomInset),
      itemCount: layout.monthCount,
      itemExtentBuilder: (index, _) => layout.monthExtent(index),
      itemBuilder: (context, index) {
        final month = layout.monthAt(index);
        return CalendarMonthSection(
          month: month,
          layout: layout,
          // --- Le mois déjà nommé dans l'en-tête ne répète pas son titre ---
          showTitle: month != visibleMonth,
          today: today,
          eventsOn: eventsOn,
          importantDatesOn: importantDatesOn,
          onDayTap: onDayTap,
        );
      },
    );
  }
}
