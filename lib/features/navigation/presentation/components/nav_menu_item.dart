// ============================================================================
// NAV MENU ITEM
// ============================================================================
// Une ligne du menu déplié : nom de l'écran + icône, sous forme de pilule.
// Composant "bête" : ne connaît ni le ViewModel ni GoRouter, uniquement des
// données et un callback.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/nav_destination.dart';

class NavMenuItem extends StatelessWidget {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // --- On désactive le tap si on est déjà sur cet écran ---
          onTap: isCurrent ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrent ? amorDarkRose : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  destination.label,
                  style: TextStyle(
                    color: isCurrent ? Colors.white : amorDarkRose,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  destination.icon,
                  color: isCurrent ? Colors.white : amorDarkRose,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}