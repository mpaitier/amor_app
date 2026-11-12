// ============================================================================
// CALENDAR MONTH TITLE
// ============================================================================
// Titre glissé entre deux mois dans la liste ("Novembre 2026").

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/calendar_month.dart';
import '../utils/calendar_labels.dart';

class CalendarMonthTitle extends StatelessWidget {
  final CalendarMonth month;

  const CalendarMonthTitle({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          formatMonthYear(month),
          maxLines: 1,
          style: const TextStyle(
            color: amorDarkRose,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
