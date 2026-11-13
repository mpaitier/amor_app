// ============================================================================
// IMPORTANT DATE COLOR SWATCH
// ============================================================================
// Pastille d'une couleur. Celle qui est retenue est entourée d'un anneau.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ImportantDateColorSwatch extends StatelessWidget {
  final int color;
  final bool isSelected;
  final VoidCallback onTap;

  const ImportantDateColorSwatch({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? amorDarkRose : Colors.transparent,
            width: 2,
          ),
        ),
        // --- Le liseré gris garde les teintes claires visibles sur le fond ---
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(color),
            border: Border.all(color: outlineVariantLight),
          ),
        ),
      ),
    );
  }
}
