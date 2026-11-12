// ============================================================================
// CALENDAR WEEKDAY ROW
// ============================================================================
// Initiales des jours, du lundi au dimanche. Reprend les marges de
// CalendarWeekRow pour que chaque lettre tombe au-dessus de sa colonne.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/calendar_layout.dart';
import '../utils/calendar_labels.dart';

class CalendarWeekdayRow extends StatelessWidget {
  const CalendarWeekdayRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalendarLayout.rowSidePadding,
      ),
      child: Row(
        children: [
          for (final initial in calendarWeekdayInitials)
            Expanded(
              child: Text(
                initial,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: amorDarkRose,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
