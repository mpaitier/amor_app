// ============================================================================
// NOTIFICATION REMINDER ROW
// ============================================================================
// Le rappel sur une ligne : "− 1 + jour avant à 18:00". Le nombre se tape
// au clavier ou aux boutons, l'heure s'ouvre d'un tap. Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../important_dates/presentation/components/occurrence_limit_stepper.dart';
import '../utils/clock_labels.dart';
import '../utils/clock_picker.dart';

class NotificationReminderRow extends StatelessWidget {
  final int daysBefore;
  final int minDays;
  final int maxDays;

  // --- Minutes depuis minuit ---
  final int time;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<int> onTimeChanged;

  const NotificationReminderRow({
    super.key,
    required this.daysBefore,
    required this.minDays,
    required this.maxDays,
    required this.time,
    required this.onDaysChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      // --- Sur un écran étroit, la ligne rétrécit au lieu de déborder ---
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        // --- Taille minimale : FittedBox ne borne pas la largeur ---
        mainAxisSize: MainAxisSize.min,
        children: [
          OccurrenceLimitStepper(
            value: daysBefore,
            min: minDays,
            max: maxDays,
            unit: daysBefore > 1 ? 'jours avant à' : 'jour avant à',
            onChanged: onDaysChanged,
            compact: true,
          ),
          TextButton(
            onPressed: () => _pickTime(context),
            child: Text(
              formatClock(time),
              style: const TextStyle(
                color: amorDarkRose,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await pickClockTime(context, time);
    if (picked != null) onTimeChanged(picked);
  }
}
