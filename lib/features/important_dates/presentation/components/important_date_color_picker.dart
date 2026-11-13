// ============================================================================
// IMPORTANT DATE COLOR PICKER
// ============================================================================
// Une rangée de pastilles de couleur. Composant "bête" : sert aussi bien au
// fond qu'à la bordure, selon la liste et le callback reçus.

import 'package:flutter/material.dart';
import 'important_date_color_swatch.dart';

class ImportantDateColorPicker extends StatelessWidget {
  final List<int> colors;
  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  const ImportantDateColorPicker({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final color in colors)
          ImportantDateColorSwatch(
            color: color,
            isSelected: color == selectedColor,
            onTap: () => onColorSelected(color),
          ),
      ],
    );
  }
}
