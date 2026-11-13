// ============================================================================
// RECENT COLORS ROW
// ============================================================================
// Pastilles des couleurs personnalisées déjà utilisées sur ce téléphone.
// Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RecentColorsRow extends StatelessWidget {
  final List<int> colors;
  final ValueChanged<int> onColorSelected;

  const RecentColorsRow({
    super.key,
    required this.colors,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récentes',
          style: TextStyle(color: outlineLight, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final color in colors)
              InkWell(
                onTap: () => onColorSelected(color),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(color),
                    border: Border.all(color: outlineVariantLight),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
