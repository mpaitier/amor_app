// ============================================================================
// NOTIFICATION TIME TILE
// ============================================================================
// "Le jour même · 09:00" : un tap ouvre le sélecteur d'heure. Grisée et
// inerte quand onChanged est nul. Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/clock_labels.dart';

class NotificationTimeTile extends StatelessWidget {
  final String label;

  // --- Minutes depuis minuit ---
  final int minutes;
  final ValueChanged<int>? onChanged;
  final double indent;

  const NotificationTimeTile({
    super.key,
    required this.label,
    required this.minutes,
    required this.onChanged,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: InkWell(
        onTap: isEnabled ? () => _pickTime(context) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: 20,
                color: isEnabled ? amorDarkRose : outlineLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? onBackgroundLight : outlineLight,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                formatClock(minutes),
                style: TextStyle(
                  color: isEnabled ? amorDarkRose : outlineLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      // --- Format 24 h, quelle que soit la langue du téléphone ---
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) onChanged?.call(picked.hour * 60 + picked.minute);
  }
}
