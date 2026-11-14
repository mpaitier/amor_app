// ============================================================================
// TIMELINE SCREEN
// ============================================================================
// Main screen listing all memories, with the upcoming anniversaries.
// TimelineViewModel is provided per relationship (couple_scoped_providers);
// UpcomingSpecialDaysViewModel lives with this screen. EndRequestPrompt
// asks for an answer when an end request is waiting for this person.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../../../couple/presentation/components/end_request_prompt.dart';
import '../../../navigation/presentation/components/floating_add_button.dart';
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

          // --- Ajout d'un souvenir ou d'une date, bas-gauche ---
          FloatingAddButton(),

          // --- Menu de navigation flottant, bas-droite ---
          FloatingNavMenu(currentRoute: AppRoutes.mainMenu),

          // --- Demande d'arrêt en attente de réponse (rien d'affiché) ---
          EndRequestPrompt(),
        ],
      ),
    );
  }
}
