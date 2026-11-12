// ============================================================================
// CALENDAR MONTH TITLE BUTTON
// ============================================================================
// Mois et année de l'en-tête. Se présente comme un simple texte, mais un tap
// ouvre le sélecteur de mois.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/calendar_month.dart';
import '../utils/calendar_labels.dart';

class CalendarMonthTitleButton extends StatelessWidget {
  final CalendarMonth month;
  final VoidCallback onTap;

  const CalendarMonthTitleButton({
    super.key,
    required this.month,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      hint: 'Changer de mois',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            formatMonthYear(month),
            style: const TextStyle(
              color: amorDarkRose,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
