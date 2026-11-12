// ============================================================================
// NAV DESTINATIONS
// ============================================================================
// Source unique de vérité pour les écrans accessibles via le menu flottant.

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
  NavDestination(
    id: 'calendar',
    label: 'Calendrier',
    icon: Icons.calendar_month,
    routePath: AppRoutes.calendar,
  ),
];