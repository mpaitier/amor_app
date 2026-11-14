// ============================================================================
// TEST UNITAIRE : resolveSessionRedirect
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/auth/presentation/viewmodels/auth_session_viewmodel.dart';
import 'package:amor_app/navigation/app_routes.dart';
import 'package:amor_app/navigation/session_redirect.dart';

void main() {
  group('état inconnu', () {
    test('envoie vers le chargement', () {
      expect(
        resolveSessionRedirect(
          status: AuthStatus.unknown,
          location: AppRoutes.mainMenu,
        ),
        AppRoutes.splash,
      );
    });

    test('laisse sur le chargement', () {
      expect(
        resolveSessionRedirect(
          status: AuthStatus.unknown,
          location: AppRoutes.splash,
        ),
        isNull,
      );
    });
  });

  group('déconnecté', () {
    test('envoie vers la connexion depuis n\'importe quel écran', () {
      for (final location in [
        AppRoutes.splash,
        AppRoutes.mainMenu,
        AppRoutes.settings,
        AppRoutes.calendar,
      ]) {
        expect(
          resolveSessionRedirect(
            status: AuthStatus.signedOut,
            location: location,
          ),
          AppRoutes.signIn,
          reason: location,
        );
      }
    });

    test('laisse sur la connexion', () {
      expect(
        resolveSessionRedirect(
          status: AuthStatus.signedOut,
          location: AppRoutes.signIn,
        ),
        isNull,
      );
    });
  });

  group('connecté', () {
    test('quitte les écrans d\'entrée pour le journal', () {
      for (final location in [AppRoutes.splash, AppRoutes.signIn]) {
        expect(
          resolveSessionRedirect(
            status: AuthStatus.signedIn,
            location: location,
          ),
          AppRoutes.mainMenu,
          reason: location,
        );
      }
    });

    test('laisse sur les autres écrans', () {
      expect(
        resolveSessionRedirect(
          status: AuthStatus.signedIn,
          location: AppRoutes.calendar,
        ),
        isNull,
      );
    });
  });
}
