// ============================================================================
// OCCURRENCE LIMIT STEPPER
// ============================================================================
// Compteur "− 5 fois +" pour le nombre de répétitions. Composant "bête" :
// reçoit la valeur, ses bornes et un callback.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OccurrenceLimitStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const OccurrenceLimitStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          tooltip: 'Une fois de moins',
          icon: const Icon(Icons.remove_circle_outline),
          color: amorDarkRose,
        ),
        SizedBox(
          width: 80,
          child: Text(
            '$value fois',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: onBackgroundLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          tooltip: 'Une fois de plus',
          icon: const Icon(Icons.add_circle_outline),
          color: amorDarkRose,
        ),
      ],
    );
  }
}
