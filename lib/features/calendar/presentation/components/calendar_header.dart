// ============================================================================
// CALENDAR HEADER
// ============================================================================
// En-tête fixe du calendrier : le mois affiché (cliquable) et la ligne des
// jours de la semaine. Composant "bête" : reçoit
// tout en paramètre.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/calendar_month.dart';
import 'calendar_month_title_button.dart';
import 'calendar_weekday_row.dart';

class CalendarHeader extends StatelessWidget {
  final CalendarMonth month;
  final VoidCallback onMonthTap;

  const CalendarHeader({
    super.key,
    required this.month,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: amorCreamTransparent,
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // --- Contrepoids du bouton d'ajout, pour centrer le mois ---
                const SizedBox(width: 48),

                Expanded(
                  child: Center(
                    child: CalendarMonthTitleButton(
                      month: month,
                      onTap: onMonthTap,
                    ),
                  ),
                ),

                // --- Même largeur à droite, pour garder le mois au centre ---
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const CalendarWeekdayRow(),
        ],
      ),
    );
  }
}
