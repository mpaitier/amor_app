// ============================================================================
// SETTINGS SECTION
// ============================================================================
// Un bloc de l'écran : un intitulé, puis son contenu dans une carte blanche.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: const TextStyle(
              color: amorDarkRose,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Material(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ),
      ],
    );
  }
}
