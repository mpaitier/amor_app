// ============================================================================
// TIMELINE SCREEN
// ============================================================================
// Main screen listing all memories, with the upcoming anniversaries.
// TimelineViewModel is provided once at the app root (see main.dart);
// UpcomingSpecialDaysViewModel lives with this screen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../../../navigation/presentation/components/floating_nav_menu.dart';
import '../../../settings/domain/usecases/get_upcoming_special_days.dart';
import '../components/timeline_top_bar.dart';
import '../components/timeline_event_list.dart';
import '../viewmodels/upcoming_special_days_viewmodel.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpcomingSpecialDaysViewModel(
        watchCoupleSettings: sl.watchCoupleSettings,
        getUpcomingSpecialDays: const GetUpcomingSpecialDays(),
      ),
      child: const Stack(
        // --- Stack requis : FloatingNavMenu se positionne via Positioned ---
        children: [
          Column(
            children: [
              // --- Top bar with sorting and add button ---
              TimelineTopBar(),

              // --- Scrollable list of events ---
              Expanded(child: TimelineEventList()),
            ],
          ),

          // --- Menu de navigation flottant, bas-droite ---
          FloatingNavMenu(currentRoute: AppRoutes.mainMenu),
        ],
      ),
    );
  }
}
