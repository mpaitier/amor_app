// ============================================================================
// FLOATING NAV MENU
// ============================================================================
// Point d'entrée de la feature : crée le ViewModel et connecte les
// composants visuels. À placer dans un Stack, en bas à droite de l'écran.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../navigation/nav_destinations.dart';
import '../viewmodels/nav_menu_viewmodel.dart';
import 'nav_menu_button.dart';
import 'nav_menu_list.dart';

class FloatingNavMenu extends StatelessWidget {
  final String currentRoute;

  const FloatingNavMenu({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavMenuViewModel(),
      child: Consumer<NavMenuViewModel>(
        builder: (context, viewModel, _) {
          // --- Retrouve la destination correspondant à l'écran courant ---
          final matches =
              navDestinations.where((d) => d.routePath == currentRoute).toList();
          final currentDestination = matches.isNotEmpty ? matches.first : null;

          return Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                NavMenuList(
                  isExpanded: viewModel.isExpanded,
                  destinations: navDestinations,
                  currentRoute: currentRoute,
                  viewModel: viewModel,
                ),
                const SizedBox(height: 12),
                NavMenuButton(
                  currentDestination: currentDestination,
                  isExpanded: viewModel.isExpanded,
                  onTap: viewModel.toggle,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}