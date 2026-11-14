// ============================================================================
// SESSION REDIRECT
// ============================================================================
// Décide où envoyer la personne selon son état de connexion. Fonction pure,
// appelée par le redirect de GoRouter et testée seule.

import '../features/auth/presentation/viewmodels/auth_session_viewmodel.dart';
import 'app_routes.dart';

// --- Renvoie la route cible, ou null pour rester où l'on est ---
String? resolveSessionRedirect({
  required AuthStatus status,
  required String location,
}) {
  switch (status) {
    case AuthStatus.unknown:
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    case AuthStatus.signedOut:
      return location == AppRoutes.signIn ? null : AppRoutes.signIn;
    case AuthStatus.signedIn:
      final isOnEntryScreen =
          location == AppRoutes.signIn || location == AppRoutes.splash;
      return isOnEntryScreen ? AppRoutes.mainMenu : null;
  }
}
