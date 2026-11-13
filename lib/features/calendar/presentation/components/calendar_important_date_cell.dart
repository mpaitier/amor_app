// ============================================================================
// CALENDAR IMPORTANT DATE CELL
// ============================================================================
// Case d'un jour qui porte une date importante, sans souvenir : le numéro
// monte au-dessus, la case prend le fond, la bordure et l'emoji choisis.

import 'package:flutter/material.dart';
import '../../../important_dates/domain/entities/important_date_entity.dart';
import '../../../important_dates/presentation/components/important_date_tile.dart';
import 'calendar_day_number_label.dart';

class CalendarImportantDateCell extends StatelessWidget {
  final int day;
  final ImportantDateEntity date;
  final VoidCallback onTap;

  const CalendarImportantDateCell({
    super.key,
    required this.day,
    required this.date,
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
                  emoji: date.emoji,
                  backgroundColor: date.backgroundColor,
                  borderColor: date.borderColor,
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
