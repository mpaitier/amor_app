// ============================================================================
// NAV DESTINATIONS
// ============================================================================
// Source unique de vérité pour les écrans accessibles via le menu flottant.
// Pour ajouter un écran au menu (ex: le futur calendrier), il suffira
// d'ajouter une entrée ici.

import 'package:flutter/material.dart';
import '../features/navigation/presentation/models/nav_destination.dart';
import 'app_routes.dart';

const List<NavDestination> navDestinations = [
  NavDestination(
    id: 'timeline',
    label: 'Notre histoire',
    icon: Icons.favorite,
    routePath: AppRoutes.mainMenu,
  ),
  // --- Le calendrier sera ajouté ici dans une prochaine étape ---
];