// ============================================================================
// TEST UNITAIRE : vérifications du formulaire de connexion
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/auth/domain/entities/auth_failure.dart';
import 'package:amor_app/features/auth/presentation/utils/auth_messages.dart';

void main() {
  group('validateEmail', () {
    test('accepte une adresse correcte, espaces compris', () {
      expect(validateEmail(' lulu@amor.fr '), isNull);
    });

    test('refuse une adresse vide ou mal formée', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('   '), isNotNull);
      expect(validateEmail('lulu'), isNotNull);
      expect(validateEmail('lulu@amor'), isNotNull);
    });
  });

  group('validatePassword', () {
    test('refuse un mot de passe vide', () {
      expect(validatePassword('', isRegistering: false), isNotNull);
    });

    test('n\'impose la longueur minimale qu\'à la création de compte', () {
      expect(validatePassword('abc', isRegistering: false), isNull);
      expect(validatePassword('abc', isRegistering: true), isNotNull);
      expect(validatePassword('abcdef', isRegistering: true), isNull);
    });
  });

  group('validateConfirmation', () {
    test('accepte deux mots de passe identiques', () {
      expect(validateConfirmation('secret', 'secret'), isNull);
    });

    test('refuse deux mots de passe différents', () {
      expect(validateConfirmation('secret', 'secrète'), isNotNull);
    });
  });

  test('chaque raison d\'échec a un message', () {
    for (final reason in AuthFailureReason.values) {
      expect(authFailureMessage(reason), isNotEmpty, reason: reason.name);
    }
  });
}
