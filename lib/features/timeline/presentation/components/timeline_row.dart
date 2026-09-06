// ============================================================================
// TIMELINE ROW
// ============================================================================
// Full row: date column + event card, shown in the events list.

import 'package:flutter/material.dart';
import '../../domain/entities/timeline_event_entity.dart';
import 'timeline_date_column.dart';
import 'timeline_event_card.dart';

class TimelineRow extends StatelessWidget {
  final TimelineEventEntity event;
  final VoidCallback onTap;

  const TimelineRow({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Date column (15% of width) ---
        Flexible(
          flex: 15,
          child: TimelineDateColumn(event: event),
        ),

        const SizedBox(width: 8),

        // --- Event card (85% of width) ---
        Flexible(
          flex: 85,
          child: GestureDetector(
            onTap: onTap,
            child: TimelineEventCard(event: event),
          ),
        ),
      ],
    );
  }
}