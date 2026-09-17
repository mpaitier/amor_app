// ============================================================================
// TIMELINE SCREEN
// ============================================================================
// Main screen listing all memories.
// TimelineViewModel is provided once at the app root (see main.dart).

import 'package:flutter/material.dart';
import '../../../../navigation/app_routes.dart';
import '../../../navigation/presentation/components/floating_nav_menu.dart';
import '../components/timeline_top_bar.dart';
import '../components/timeline_event_list.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      // --- Stack requis : FloatingNavMenu se positionne via Positioned ---
      child: Stack(
        children: [
          const Column(
            children: [
              // --- Top bar with sorting and add button ---
              TimelineTopBar(),

              // --- Scrollable list of events ---
              Expanded(child: TimelineEventList()),
            ],
          ),

          // --- Menu de navigation flottant, bas-droite ---
          const FloatingNavMenu(currentRoute: AppRoutes.mainMenu),
        ],
      ),
    );
  }
}