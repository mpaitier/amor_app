// ============================================================================
// CALENDAR MONTH SECTION
// ============================================================================
// Un mois dans la liste : son titre, puis ses semaines. Sa hauteur totale
// doit rester égale à CalendarLayout.monthExtent, que la liste utilise pour
// placer chaque mois.

import 'package:flutter/material.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../../domain/entities/calendar_month.dart';
import '../models/calendar_layout.dart';
import 'calendar_month_title.dart';
import 'calendar_week_row.dart';

class CalendarMonthSection extends StatelessWidget {
  final CalendarMonth month;
  final CalendarLayout layout;
  final bool showTitle;
  final DateTime today;
  final List<TimelineEventEntity> Function(DateTime day) eventsOn;
  final void Function(List<TimelineEventEntity> events) onEventsTap;

  const CalendarMonthSection({
    super.key,
    required this.month,
    required this.layout,
    required this.showTitle,
    required this.today,
    required this.eventsOn,
    required this.onEventsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- La place du titre est réservée même quand il est masqué ---
        SizedBox(
          height: CalendarLayout.monthTitleHeight,
          child: showTitle ? CalendarMonthTitle(month: month) : null,
        ),

        for (final week in month.weeks)
          CalendarWeekRow(
            days: week,
            rowHeight: layout.rowHeight,
            today: today,
            eventsOn: eventsOn,
            onEventsTap: onEventsTap,
          ),
      ],
    );
  }
}
