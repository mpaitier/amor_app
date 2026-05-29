// <<===========================================================================>>
// <<=========================== ROUTEUR DE L'APP ==============================>>
// <<===========================================================================>>
// Équivalent de AppNavigation.kt — configuration de toutes les routes

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/screens/questionnaire/questionnaire_screen.dart';
import '../ui/screens/questionnaire/year_screen.dart';
import '../ui/screens/questionnaire/gift_screen.dart';
import '../ui/screens/timeline/timeline_screen.dart';
import '../ui/screens/timeline/event_detail_screen.dart';
import '../ui/screens/timeline/add_event_screen.dart';
import 'screen.dart';

// <<--- Fonction pour déterminer la route de départ --->
Future<String> _getStartRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('is_first_run') ?? true;
  return isFirstRun ? AppRoutes.nameQuestion : AppRoutes.mainMenu;
}

// <<--- Configuration du routeur GoRouter --->
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.mainMenu,

  // <<--- Redirection au démarrage selon premier lancement --->
  redirect: (context, state) async {
    if (state.matchedLocation == AppRoutes.mainMenu) {
      return await _getStartRoute();
    }
    return null;
  },

  routes: [
    // <<--- Route principale : Timeline --->
    GoRoute(
      path: AppRoutes.mainMenu,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: TimelineScreen(),
      ),
    ),

    // <<--- Route questionnaire : Nom --->
    GoRoute(
      path: AppRoutes.nameQuestion,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: QuestionnaireScreen(),
      ),
    ),

    // <<--- Route questionnaire : Année --->
    GoRoute(
      path: AppRoutes.yearQuestion,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: YearScreen(),
      ),
    ),

    // <<--- Route cadeau --->
    GoRoute(
      path: AppRoutes.gift,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: GiftScreen(),
      ),
    ),

    // <<--- Route ajout/édition d'un événement --->
    GoRoute(
      path: AppRoutes.addTimeline,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return NoTransitionPage(
          child: AddEventScreen(
            eventToEdit: extra?['eventToEdit'],
          ),
        );
      },
    ),

    // <<--- Route détail d'un événement --->
    GoRoute(
      path: AppRoutes.timelineDetail,
      pageBuilder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return CustomTransitionPage(
          child: EventDetailScreen(eventId: eventId),
          // <<--- Animation slide depuis la droite --->
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
  ],
);