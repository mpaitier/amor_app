// ============================================================================
// CALENDAR DAY NUMBER LABEL
// ============================================================================
// Numéro du jour monté en petit au-dessus de sa case, quand celle-ci est
// occupée par un souvenir ou une date importante.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/calendar_layout.dart';

class CalendarDayNumberLabel extends StatelessWidget {
  final int day;

  const CalendarDayNumberLabel({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CalendarLayout.dayNumberHeight,
      child: Center(
        child: Text(
          '$day',
          style: const TextStyle(
            color: amorDarkRose,
            fontSize: 11,
            height: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
