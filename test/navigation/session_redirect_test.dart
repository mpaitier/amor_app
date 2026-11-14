// ============================================================================
// TEST UNITAIRE : resolveSessionRedirect
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/couple/presentation/viewmodels/couple_session_viewmodel.dart';
import 'package:amor_app/navigation/app_routes.dart';
import 'package:amor_app/navigation/session_redirect.dart';

void main() {
  String? redirect(SessionStatus status, String location) {
    return resolveSessionRedirect(status: status, location: location);
  }

  group('chargement', () {
    test('envoie vers le chargement', () {
      expect(redirect(SessionStatus.loading, AppRoutes.mainMenu),
          AppRoutes.splash);
      expect(redirect(SessionStatus.loading, '/join/K7PQ2A'),
          AppRoutes.splash);
    });

    test('laisse sur le chargement', () {
      expect(redirect(SessionStatus.loading, AppRoutes.splash), isNull);
    });
  });

  group('déconnecté', () {
    test('envoie vers la connexion depuis n\'importe quel écran', () {
      for (final location in [
        AppRoutes.splash,
        AppRoutes.mainMenu,
        AppRoutes.settings,
        AppRoutes.coupleSetup,
        '/join/K7PQ2A',
      ]) {
        expect(redirect(SessionStatus.signedOut, location), AppRoutes.signIn,
            reason: location);
      }
    });

    test('laisse sur la connexion', () {
      expect(redirect(SessionStatus.signedOut, AppRoutes.signIn), isNull);
    });
  });

  group('sans relation', () {
    test('envoie vers la création de relation', () {
      for (final location in [
        AppRoutes.splash,
        AppRoutes.signIn,
        AppRoutes.mainMenu,
        '/join/K7PQ2A',
      ]) {
        expect(redirect(SessionStatus.needsCouple, location),
            AppRoutes.coupleSetup,
            reason: location);
      }
    });

    test('laisse sur la création de relation', () {
      expect(redirect(SessionStatus.needsCouple, AppRoutes.coupleSetup),
          isNull);
    });
  });

  group('prêt', () {
    test('quitte les écrans d\'entrée et les liens pour le journal', () {
      for (final location in [
        AppRoutes.splash,
        AppRoutes.signIn,
        AppRoutes.coupleSetup,
        '/join/K7PQ2A',
      ]) {
        expect(redirect(SessionStatus.ready, location), AppRoutes.mainMenu,
            reason: location);
      }
    });

    test('laisse sur les autres écrans', () {
      expect(redirect(SessionStatus.ready, AppRoutes.calendar), isNull);
      expect(redirect(SessionStatus.ready, AppRoutes.mainMenu), isNull);
    });
  });
}
