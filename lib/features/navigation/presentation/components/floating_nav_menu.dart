// ============================================================================
// FLOATING NAV MENU
// ============================================================================
// Point d'entrée de la feature : crée le ViewModel et connecte les
// composants visuels. À placer dans un Stack plein écran. Le bouton est en
// bas à droite ; ouvert, le menu dispose les écrans en arc autour de lui
// (RadialMenuLayout) et un voile transparent le referme au moindre tap
// ailleurs. Seul endroit de la feature qui déclenche une navigation.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../navigation/nav_destinations.dart';
import '../models/nav_destination.dart';
import '../models/radial_menu_layout.dart';
import '../viewmodels/nav_menu_viewmodel.dart';
import 'nav_menu_button.dart';
import 'nav_menu_item.dart';

class FloatingNavMenu extends StatelessWidget {
  final String currentRoute;

  const FloatingNavMenu({super.key, required this.currentRoute});

  // --- Marge entre le bouton et les bords de l'écran ---
  static const double _margin = 16;
  static const double _buttonSize = 56;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavMenuViewModel(),
      // --- Positioned.fill : le calque couvre l'écran, mais sans fond, il
      // --- laisse passer les taps tant que le menu est fermé ---
      child: Positioned.fill(
        child: Consumer<NavMenuViewModel>(
          builder: (context, viewModel, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return _buildLayer(context, viewModel, constraints.biggest);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLayer(
    BuildContext context,
    NavMenuViewModel viewModel,
    Size area,
  ) {
    final isExpanded = viewModel.isExpanded;
    final anchor = Offset(
      area.width - _margin - _buttonSize / 2,
      area.height - _margin - _buttonSize / 2,
    );
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
              onTap: viewModel.close,
            ),
          ),

        // --- Entrées, qui partent du bouton et s'écartent en arc ---
        for (var i = 0; i < navDestinations.length; i++)
          _buildItem(
            context,
            viewModel,
            destination: navDestinations[i],
            center: isExpanded ? anchor + offsets[i] : anchor,
            isExpanded: isExpanded,
          ),

        Positioned(
          right: _margin,
          bottom: _margin,
          child: NavMenuButton(
            currentDestination: currentDestination,
            isExpanded: isExpanded,
            onTap: viewModel.toggle,
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
  }) {
    // --- La bulle (et non le libellé) est centrée sur sa place dans l'arc ---
    const bubbleCenterY = NavMenuItem.bubbleSize / 2;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
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
