// ============================================================================
// COUPLE SETUP HEADER
// ============================================================================
// Titre et explication en haut de l'écran de création de relation.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cream_label.dart';

class CoupleSetupHeader extends StatelessWidget {
  const CoupleSetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CreamLabel(
          text: 'Votre relation',
          style: TextStyle(
            color: amorDarkRose,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        CreamLabel(
          text: 'Crée-la et invite ta moitié, ou rejoins celle qui t\'attend.',
          maxLines: 3,
          textAlign: TextAlign.center,
          style: TextStyle(color: amorDarkRose, fontSize: 15),
        ),
      ],
    );
  }
}
