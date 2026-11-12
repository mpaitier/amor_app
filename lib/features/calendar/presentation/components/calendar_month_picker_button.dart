// ============================================================================
// CALENDAR MONTH PICKER BUTTON
// ============================================================================
// Un mois dans le sélecteur. Rempli quand c'est le mois affiché, grisé
// quand il est hors de la plage du calendrier (onTap nul).

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CalendarMonthPickerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CalendarMonthPickerButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: isSelected ? amorDarkRose : outlineVariantLight,
      ),
    );

    return Material(
      color: isSelected ? amorDarkRose : backgroundLight,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _labelColor,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get _labelColor {
    if (isSelected) return Colors.white;
    if (onTap == null) return outlineLight;
    return onBackgroundLight;
  }
}
