// <<===========================================================================>>
// <<=========================== LIGNE TIMELINE ================================>>
// <<===========================================================================>>
// Équivalent de Row.kt — ligne complète date + carte dans la liste

import 'package:flutter/material.dart';
import '../../../data/models/timeline_event.dart';
import 'timeline_date_column.dart';
import 'timeline_event_card.dart';

class TimelineRow extends StatelessWidget {
  // <<--- Paramètres --->
  final TimelineEvent event;
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
        // <<--- Colonne date (15% de la largeur) --->
        Flexible(
          flex: 15,
          child: TimelineDateColumn(event: event),
        ),

        const SizedBox(width: 8),

        // <<--- Carte événement (85% de la largeur) --->
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