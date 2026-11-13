// ============================================================================
// SETTINGS TOP BAR
// ============================================================================
// Bouton retour à gauche, titre centré, même habillage que l'en-tête du
// journal. Composant "bête" : reçoit l'action de retour.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const SettingsTopBar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: amorCreamTransparent,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Retour',
            icon: const Icon(Icons.arrow_back, color: amorDarkRose),
          ),
          const Expanded(
            child: Text(
              'Paramètres',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: amorDarkRose,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // --- Contrepoids du bouton retour, pour centrer le titre ---
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
