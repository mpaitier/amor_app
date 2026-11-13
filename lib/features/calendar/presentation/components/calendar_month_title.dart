// ============================================================================
// CALENDAR MONTH TITLE
// ============================================================================
// Titre glissé entre deux mois dans la liste ("Novembre 2026"), sur
// pastille crème pour rester lisible sur le fond.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cream_label.dart';
import '../../domain/entities/calendar_month.dart';
import '../utils/calendar_labels.dart';

class CalendarMonthTitle extends StatelessWidget {
  final CalendarMonth month;

  const CalendarMonthTitle({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 16, bottom: 6),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: CreamLabel(
          text: formatMonthYear(month),
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
