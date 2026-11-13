// ============================================================================
// CALENDAR SPECIAL DAY CELL
// ============================================================================
// Case d'un jour spécial sans souvenir (date importante, anniversaire,
// mois-anniversaire) : le numéro monte au-dessus, la case prend le fond,
// la bordure et l'emoji choisis.

import 'package:flutter/material.dart';
import '../../../important_dates/presentation/components/important_date_tile.dart';
import '../../domain/entities/calendar_special_day.dart';
import 'calendar_day_number_label.dart';

class CalendarSpecialDayCell extends StatelessWidget {
  final int day;
  final CalendarSpecialDay specialDay;
  final VoidCallback onTap;

  const CalendarSpecialDayCell({
    super.key,
    required this.day,
    required this.specialDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CalendarDayNumberLabel(day: day),

        // --- Case, avec l'effet d'encre dessiné par-dessus ---
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImportantDateTile(
                  emoji: specialDay.emoji,
                  backgroundColor: specialDay.backgroundColor,
                  borderColor: specialDay.borderColor,
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(onTap: onTap),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
