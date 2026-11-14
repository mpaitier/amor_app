// ============================================================================
// SESSION REDIRECT
// ============================================================================
// Décide où envoyer la personne selon sa session : connexion, relation à
// créer, ou app. Fonction pure, appelée par le redirect de GoRouter et
// testée seule.

import '../features/couple/presentation/viewmodels/couple_session_viewmodel.dart';
import 'app_routes.dart';

// --- Écrans qu'on quitte dès que la session est prête ---
const Set<String> _entryRoutes = {
  AppRoutes.splash,
  AppRoutes.signIn,
  AppRoutes.coupleSetup,
};

// --- Renvoie la route cible, ou null pour rester où l'on est ---
String? resolveSessionRedirect({
  required SessionStatus status,
  required String location,
}) {
  switch (status) {
    case SessionStatus.loading:
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    case SessionStatus.signedOut:
      return location == AppRoutes.signIn ? null : AppRoutes.signIn;
    case SessionStatus.needsCouple:
      return location == AppRoutes.coupleSetup ? null : AppRoutes.coupleSetup;
    case SessionStatus.ready:
      final isEntry =
          _entryRoutes.contains(location) || location.startsWith('/join/');
      return isEntry ? AppRoutes.mainMenu : null;
  }
}
