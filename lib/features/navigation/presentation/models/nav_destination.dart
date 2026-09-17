// ============================================================================
// NAV DESTINATION (UI MODEL)
// ============================================================================
// Carte d'identité d'un écran accessible depuis le menu de navigation.
// Ce n'est PAS une entité de domaine : elle porte une IconData, qui est un
// type Flutter, donc elle vit dans la couche presentation (comme ImageItem).

import 'package:flutter/material.dart';

class NavDestination {
  final String id;
  final String label;
  final IconData icon;
  final String routePath;

  const NavDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.routePath,
  });
}