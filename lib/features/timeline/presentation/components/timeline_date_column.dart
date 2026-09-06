// ============================================================================
// TIMELINE DATE COLUMN
// ============================================================================
// Month / day / year badge shown next to each event in the list.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/timeline_event_entity.dart';

class TimelineDateColumn extends StatelessWidget {
  final TimelineEventEntity event;

  const TimelineDateColumn({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: amorDarkRose, width: 2),
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonth(),
            _buildDay(),
            _buildYear(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonth() {
    final month = DateFormat('MMM', 'fr_FR').format(event.date).toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFC6C6C6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Text(
        month,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF424242),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildDay() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: Text(
        '${event.date.day}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: amorDarkRose,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildYear() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.only(top: 2, bottom: 6, left: 6, right: 6),
      child: Text(
        '${event.date.year}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF424242),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}