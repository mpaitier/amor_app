// ============================================================================
// IMPORTANT DATE COLOR ROW
// ============================================================================
// Un intitulé, puis une rangée de pastilles qui défile à l'horizontale.
// Composant "bête" : sert aussi bien à la bordure qu'au fond, selon la
// liste et le callback reçus.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'important_date_color_swatch.dart';

class ImportantDateColorRow extends StatelessWidget {
  final String label;
  final List<int> colors;
  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  const ImportantDateColorRow({
    super.key,
    required this.label,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: amorDarkRose,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),

        // --- Hauteur fixe : une liste horizontale en a besoin dans un
        // --- formulaire qui défile à la verticale ---
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final color = colors[index];
              return ImportantDateColorSwatch(
                color: color,
                isSelected: color == selectedColor,
                onTap: () => onColorSelected(color),
              );
            },
          ),
        ),
      ],
    );
  }
}
