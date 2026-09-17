// ============================================================================
// NAV MENU BUTTON
// ============================================================================
// Bouton rond flottant : affiche l'icône de l'écran courant replié, une
// croix quand le menu est ouvert. Composant "bête" : reçoit tout en param.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/nav_destination.dart';

class NavMenuButton extends StatelessWidget {
  final NavDestination? currentDestination;
  final bool isExpanded;
  final VoidCallback onTap;

  const NavMenuButton({
    super.key,
    required this.currentDestination,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: amorDarkRose,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            isExpanded
                ? Icons.close
                : (currentDestination?.icon ?? Icons.apps_rounded),
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}