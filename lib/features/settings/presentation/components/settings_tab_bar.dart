// ============================================================================
// SETTINGS TAB BAR
// ============================================================================
// Onglets des paramètres, façon YouTube : le trait sous l'onglet actif suit
// le glissement entre les pages, en position comme en largeur. Ce suivi
// vient du TabController partagé avec le TabBarView (DefaultTabController
// de l'écran). Composant "bête" : reçoit seulement les libellés.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsTabBar extends StatelessWidget {
  final List<String> labels;

  const SettingsTabBar({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: amorCreamTransparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        tabs: [for (final label in labels) Tab(text: label, height: 44)],
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        // --- Trait de la largeur du libellé, qui s'étire pendant le
        // --- glissement d'un onglet à l'autre ---
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: amorDarkRose, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        dividerColor: Colors.transparent,
        labelColor: amorDarkRose,
        unselectedLabelColor: onSurfaceVariantLight,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        overlayColor: WidgetStatePropertyAll(
          amorDarkRose.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
