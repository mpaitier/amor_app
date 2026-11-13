// ============================================================================
// IMPORTANT DATE COLOR ROW
// ============================================================================
// Un intitulé, puis une rangée de pastilles qui défile à l'horizontale. La
// dernière ouvre le sélecteur de couleur libre ; une couleur libre retenue
// s'affiche juste avant elle. Composant "bête" : sert aussi bien à la
// bordure qu'au fond, selon la liste et le callback reçus.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../color_history/presentation/screens/custom_color_picker.dart';
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
    final swatches = [
      ...colors,
      if (!colors.contains(selectedColor)) selectedColor,
    ];

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
            itemCount: swatches.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              if (index == swatches.length) return _buildCustomButton(context);

              final color = swatches[index];
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

  // --- Pastille arc-en-ciel : ouvre le sélecteur de couleur libre ---
  Widget _buildCustomButton(BuildContext context) {
    return Tooltip(
      message: 'Autre couleur',
      child: InkWell(
        onTap: () => _pickCustomColor(context),
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  for (var step = 0; step <= 6; step++)
                    HSVColor.fromAHSV(1, step * 60.0, 0.8, 1).toColor(),
                ],
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomColor(BuildContext context) async {
    final color = await showCustomColorPicker(
      context,
      initialColor: selectedColor,
    );
    if (color != null) onColorSelected(color);
  }
}
