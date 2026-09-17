// ============================================================================
// NAV MENU LIST
// ============================================================================
// Liste animée des NavMenuItem, affichée au-dessus du bouton quand le menu
// est déplié. Seul endroit de la feature qui déclenche une navigation.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/nav_destination.dart';
import '../viewmodels/nav_menu_viewmodel.dart';
import 'nav_menu_item.dart';

class NavMenuList extends StatelessWidget {
  final bool isExpanded;
  final List<NavDestination> destinations;
  final String currentRoute;
  final NavMenuViewModel viewModel;

  const NavMenuList({
    super.key,
    required this.isExpanded,
    required this.destinations,
    required this.currentRoute,
    required this.viewModel,
  });

  // --- Ferme le menu puis navigue vers l'écran choisi ---
  void _handleTap(BuildContext context, NavDestination destination) {
    viewModel.close();
    context.go(destination.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.bottomRight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isExpanded ? 1.0 : 0.0,
        child: !isExpanded
            ? const SizedBox.shrink()
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: destinations.map((destination) {
                  return NavMenuItem(
                    destination: destination,
                    isCurrent: destination.routePath == currentRoute,
                    onTap: () => _handleTap(context, destination),
                  );
                }).toList(),
              ),
      ),
    );
  }
}