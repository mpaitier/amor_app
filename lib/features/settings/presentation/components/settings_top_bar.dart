// ============================================================================
// SETTINGS TOP BAR
// ============================================================================
// Titre centré, même habillage que l'en-tête du journal.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsTopBar extends StatelessWidget {
  const SettingsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: amorCreamTransparent,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: const Text(
        'Paramètres',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: amorDarkRose,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
