// ============================================================================
// FLOATING NAV MENU
// ============================================================================
// Point d'entrée de la feature : crée le ViewModel du menu et connecte les
// composants visuels. À placer dans un Stack plein écran. Le bouton se
// déplace au doigt et se colle au bord le plus proche (position partagée
// par FloatingButtonsViewModel). Ouvert, le menu dispose les écrans en arc
// autour de lui (RadialMenuLayout) et un voile transparent le referme au
// moindre tap ailleurs. Seul endroit de la feature qui navigue.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../navigation/nav_destinations.dart';
import '../models/nav_destination.dart';
import '../models/radial_menu_layout.dart';
import '../viewmodels/floating_buttons_viewmodel.dart';
import '../viewmodels/nav_menu_viewmodel.dart';
import 'nav_menu_button.dart';
import 'nav_menu_item.dart';
import 'snapping_button_positioner.dart';

class FloatingNavMenu extends StatelessWidget {
  final String currentRoute;

  const FloatingNavMenu({super.key, required this.currentRoute});

  static const FloatingButtonId _id = FloatingButtonId.navigation;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavMenuViewModel(),
      // --- Positioned.fill : le calque couvre l'écran, mais sans fond, il
      // --- laisse passer les taps tant que le menu est fermé ---
      child: Positioned.fill(
        child: Consumer2<NavMenuViewModel, FloatingButtonsViewModel>(
          builder: (context, menuViewModel, buttonsViewModel, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return _buildLayer(
                  context,
                  menuViewModel,
                  buttonsViewModel,
                  constraints.biggest,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLayer(
    BuildContext context,
    NavMenuViewModel menuViewModel,
    FloatingButtonsViewModel buttonsViewModel,
    Size area,
  ) {
    final isExpanded = menuViewModel.isExpanded;
    final isDragging = buttonsViewModel.isDragging(_id);
    final anchor = buttonsViewModel.centerOf(_id, area);
    final offsets = RadialMenuLayout.offsets(
      count: navDestinations.length,
      anchor: anchor,
      area: area,
    );

    // --- Retrouve la destination correspondant à l'écran courant ---
    final matches =
        navDestinations.where((d) => d.routePath == currentRoute).toList();
    final currentDestination = matches.isNotEmpty ? matches.first : null;

    return Stack(
      children: [
        // --- Voile : un tap hors du menu le referme ---
        if (isExpanded)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: menuViewModel.close,
            ),
          ),

        // --- Entrées, qui partent du bouton et s'écartent en arc ---
        for (var i = 0; i < navDestinations.length; i++)
          _buildItem(
            context,
            menuViewModel,
            destination: navDestinations[i],
            center: isExpanded ? anchor + offsets[i] : anchor,
            isExpanded: isExpanded,
            follow: isDragging,
          ),

        SnappingButtonPositioner(
          center: anchor,
          isDragging: isDragging,
          // --- On referme le menu dès qu'on déplace le bouton ---
          onDragUpdate: (delta) {
            menuViewModel.close();
            buttonsViewModel.drag(_id, delta, area);
          },
          onDragEnd: () => buttonsViewModel.endDrag(_id, area),
          child: NavMenuButton(
            currentDestination: currentDestination,
            isExpanded: isExpanded,
            onTap: menuViewModel.toggle,
          ),
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    NavMenuViewModel viewModel, {
    required NavDestination destination,
    required Offset center,
    required bool isExpanded,
    required bool follow,
  }) {
    // --- La bulle (et non le libellé) est centrée sur sa place dans l'arc ---
    const bubbleCenterY = NavMenuItem.bubbleSize / 2;

    return AnimatedPositioned(
      // --- Repliées sous le bouton, elles le suivent sans délai ---
      duration: follow ? Duration.zero : const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      left: center.dx - NavMenuItem.width / 2,
      top: center.dy - bubbleCenterY,
      child: IgnorePointer(
        ignoring: !isExpanded,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: isExpanded ? 1 : 0,
          child: NavMenuItem(
            destination: destination,
            isCurrent: destination.routePath == currentRoute,
            onTap: () => _navigate(context, viewModel, destination),
          ),
        ),
      ),
    );
  }

  // --- Ferme le menu puis navigue vers l'écran choisi : empilé s'il
  // --- s'ouvre par-dessus, sinon à la place de l'écran courant ---
  void _navigate(
    BuildContext context,
    NavMenuViewModel viewModel,
    NavDestination destination,
  ) {
    viewModel.close();
    if (destination.opensOnTop) {
      context.push(destination.routePath);
    } else {
      context.go(destination.routePath);
    }
  }
}
