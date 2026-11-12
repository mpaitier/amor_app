// ============================================================================
// CALENDAR DAY CELL
// ============================================================================
// Case d'un jour sans souvenir : le numéro au centre. Aujourd'hui est
// entouré de rose.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/calendar_layout.dart';

class CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isToday;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Bande réservée au numéro des jours avec souvenir ---
        const SizedBox(height: CalendarLayout.dayNumberHeight),

        Expanded(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isToday ? amorPink : outlineVariantLight,
                width: isToday ? 2 : 1,
              ),
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: isToday ? amorDarkRose : onBackgroundLight,
                fontSize: 15,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
