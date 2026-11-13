// ============================================================================
// CALENDAR ANNIVERSARY SHEET
// ============================================================================
// Fiche ouverte par un tap sur un anniversaire ou un mois-anniversaire.
// Ils viennent des réglages : le seul bouton y mène. Se ferme en renvoyant
// true si l'on veut ouvrir les paramètres.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../gif/presentation/components/gif_view.dart';
import '../../../important_dates/presentation/utils/important_date_labels.dart';
import '../../domain/entities/calendar_special_day.dart';
import '../utils/calendar_labels.dart';

class CalendarAnniversarySheet extends StatelessWidget {
  final CalendarSpecialDay specialDay;
  final DateTime day;
  final DateTime today;

  const CalendarAnniversarySheet({
    super.key,
    required this.specialDay,
    required this.day,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    // --- Défilante : avec le GIF, la fiche peut dépasser la hauteur
    // --- accordée aux panneaux du bas sur un petit écran ---
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: outlineVariantLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              specialDay.emoji,
              style: const TextStyle(fontSize: 40, height: 1.0),
            ),
            const SizedBox(height: 12),
            Text(
              specialDay.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: amorDarkRose,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatDayMonthYear(day),
              style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              formatCountdown(day, today),
              style: const TextStyle(
                color: onBackgroundLight,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (specialDay.gifUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              GifView(gifUrl: specialDay.gifUrl, height: 120),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.settings, color: amorDarkRose),
              label: const Text(
                'Modifier dans les paramètres',
                style: TextStyle(color: amorDarkRose),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
