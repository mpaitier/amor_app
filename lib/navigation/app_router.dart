// ============================================================================
// APP ROUTER
// ============================================================================
// GoRouter configuration for all app routes.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/presentation/screens/questionnaire_screen.dart';
import '../features/onboarding/presentation/screens/year_screen.dart';
import '../features/onboarding/presentation/screens/gift_screen.dart';
import '../features/timeline/presentation/screens/timeline_screen.dart';
import '../features/timeline/presentation/screens/event_detail_screen.dart';
import '../features/timeline/presentation/screens/add_event_screen.dart';
import '../injection_container.dart';
import 'app_routes.dart';

// --- GoRouter configuration ---
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.mainMenu,

  // --- Redirect on startup depending on first launch ---
  redirect: (context, state) async {
    if (state.matchedLocation == AppRoutes.mainMenu) {
      final isFirstRun = await sl.checkFirstRun();
      return isFirstRun ? AppRoutes.nameQuestion : null;
    }
    return null;
  },

  routes: [
    // --- Main route: Timeline ---
    GoRoute(
      path: AppRoutes.mainMenu,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: TimelineScreen(),
      ),
    ),

    // --- Questionnaire route: Name ---
    GoRoute(
      path: AppRoutes.nameQuestion,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: QuestionnaireScreen(),
      ),
    ),

    // --- Questionnaire route: Year ---
    GoRoute(
      path: AppRoutes.yearQuestion,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: YearScreen(),
      ),
    ),

    // --- Gift route ---
    GoRoute(
      path: AppRoutes.gift,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: GiftScreen(),
      ),
    ),

    // --- Add/edit event route ---
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

    // --- Event detail route ---
    GoRoute(
      path: AppRoutes.timelineDetail,
      pageBuilder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return CustomTransitionPage(
          child: EventDetailScreen(eventId: eventId),
          // --- Slide-in animation from the right ---
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