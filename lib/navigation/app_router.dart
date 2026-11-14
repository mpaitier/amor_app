// ============================================================================
// APP ROUTER
// ============================================================================
// GoRouter configuration for all app routes. Le routeur écoute la session :
// à chaque connexion ou déconnexion, le redirect est réévalué.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/viewmodels/auth_session_viewmodel.dart';
import '../features/timeline/presentation/screens/timeline_screen.dart';
import '../features/timeline/presentation/screens/event_detail_screen.dart';
import '../features/timeline/presentation/screens/add_event_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/important_dates/presentation/screens/add_important_date_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';
import 'session_redirect.dart';

// --- GoRouter configuration ---
GoRouter createAppRouter(AuthSessionViewModel session) => GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: session,

  // --- Connexion requise partout, sauf sur les écrans d'entrée ---
  redirect: (context, state) => resolveSessionRedirect(
    status: session.status,
    location: state.matchedLocation,
  ),

  routes: [
    // --- Chargement au lancement ---
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SplashScreen(),
      ),
    ),

    // --- Connexion / création de compte ---
    GoRoute(
      path: AppRoutes.signIn,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SignInScreen(),
      ),
    ),

    // --- Main route: Timeline ---
    GoRoute(
      path: AppRoutes.mainMenu,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: TimelineScreen(),
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

    // --- Calendar route ---
    GoRoute(
      path: AppRoutes.calendar,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CalendarScreen(),
      ),
    ),

    // --- Add/edit important date route ---
    GoRoute(
      path: AppRoutes.addImportantDate,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return NoTransitionPage(
          child: AddImportantDateScreen(
            dateToEdit: extra?['dateToEdit'],
          ),
        );
      },
    ),

    // --- Settings route ---
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SettingsScreen(),
      ),
    ),
  ],
);