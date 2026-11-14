// ============================================================================
// MEMBER COLOR PICKER
// ============================================================================
// Rangée de pastilles pour choisir sa couleur. Composant "bête" : reçoit la
// couleur retenue et prévient au toucher. Réutilise la pastille des dates
// importantes.

import 'package:flutter/material.dart';
import '../../../important_dates/presentation/components/important_date_color_swatch.dart';
import '../models/member_color_palette.dart';

class MemberColorPicker extends StatelessWidget {
  final int selectedColor;
  final bool enabled;
  final ValueChanged<int> onColorSelected;

  const MemberColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final color in MemberColorPalette.colors)
          ImportantDateColorSwatch(
            color: color,
            isSelected: color == selectedColor,
            onTap: enabled ? () => onColorSelected(color) : () {},
          ),
      ],
    );
  }
}
