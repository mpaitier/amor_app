// ============================================================================
// TIMELINE UPCOMING ROW
// ============================================================================
// Annonce d'un anniversaire ou d'un mois-anniversaire à venir dans le
// journal : la même colonne de date que les souvenirs, puis le bandeau du
// jour spécial avec ses jours restants.

import 'package:flutter/material.dart';
import '../../../important_dates/presentation/components/important_date_banner.dart';
import '../../../important_dates/presentation/utils/important_date_labels.dart';
import '../../../settings/domain/entities/upcoming_special_day.dart';
import 'timeline_date_column.dart';

class TimelineUpcomingRow extends StatelessWidget {
  final UpcomingSpecialDay specialDay;
  final DateTime today;

  const TimelineUpcomingRow({
    super.key,
    required this.specialDay,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final style = specialDay.style;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- Date column (15% of width), comme pour un souvenir ---
        Flexible(
          flex: 15,
          child: TimelineDateColumn(date: specialDay.date),
        ),

        const SizedBox(width: 8),

        Flexible(
          flex: 85,
          child: ImportantDateBanner(
            emoji: style.emoji,
            title: specialDay.title,
            countdown: formatShortCountdown(specialDay.date, today),
            backgroundColor: style.backgroundColor,
            borderColor: style.borderColor,
          ),
        ),
      ],
    );
  }
}
