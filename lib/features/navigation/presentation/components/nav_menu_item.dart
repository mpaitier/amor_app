// ============================================================================
// NAV MENU ITEM
// ============================================================================
// Une entrée du menu déplié : une bulle ronde avec l'icône de l'écran et son
// nom en dessous. Celle de l'écran courant est pleine et inerte.
// Composant "bête" : ne connaît ni le ViewModel ni GoRouter.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cream_label.dart';
import '../models/nav_destination.dart';

class NavMenuItem extends StatelessWidget {
  // --- Encombrement fixe, pour centrer l'entrée sur sa place dans l'arc ---
  static const double width = 96;
  static const double height = 80;
  static const double bubbleSize = 52;

  final NavDestination destination;
  final bool isCurrent;
  final VoidCallback onTap;

  const NavMenuItem({
    super.key,
    required this.destination,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: isCurrent ? amorDarkRose : Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              // --- On désactive le tap si on est déjà sur cet écran ---
              onTap: isCurrent ? null : onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: bubbleSize,
                height: bubbleSize,
                child: Icon(
                  destination.icon,
                  color: isCurrent ? Colors.white : amorDarkRose,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          CreamLabel(
            text: destination.label,
            style: const TextStyle(
              color: amorDarkRose,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
