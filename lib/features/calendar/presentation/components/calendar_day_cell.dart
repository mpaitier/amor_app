// ============================================================================
// CALENDAR DAY CELL
// ============================================================================
// Case d'un jour sans souvenir : le numéro au centre. Aujourd'hui est
// entouré de rose et rayé, pour ne pas le confondre avec un jour spécial.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/calendar_layout.dart';
import 'calendar_today_stripes.dart';

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
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isToday ? amorPink : outlineVariantLight,
                width: isToday ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isToday)
                  CalendarTodayStripes(
                    color: amorPink.withValues(alpha: 0.18),
                  ),
                Center(child: _buildNumber()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumber() {
    final label = Text(
      '$day',
      style: TextStyle(
        color: isToday ? amorDarkRose : onBackgroundLight,
        fontSize: 15,
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
      ),
    );
    if (!isToday) return label;

    // --- Pastille blanche derrière le numéro : il reste lisible sur les
    // --- rayures ---
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: label,
    );
  }
}
