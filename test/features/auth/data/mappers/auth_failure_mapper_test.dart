// ============================================================================
// TEST UNITAIRE : authFailureReasonFromCode
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/auth/data/mappers/auth_failure_mapper.dart';
import 'package:amor_app/features/auth/domain/entities/auth_failure.dart';

void main() {
  test('les codes d\'identifiants erronés mènent tous à wrongCredentials', () {
    for (final code in [
      'invalid-credential',
      'user-not-found',
      'wrong-password',
      'INVALID_LOGIN_CREDENTIALS',
    ]) {
      expect(
        authFailureReasonFromCode(code),
        AuthFailureReason.wrongCredentials,
        reason: code,
      );
    }
  });

  test('doit traduire les codes connus', () {
    expect(authFailureReasonFromCode('invalid-email'),
        AuthFailureReason.invalidEmail);
    expect(authFailureReasonFromCode('email-already-in-use'),
        AuthFailureReason.emailAlreadyInUse);
    expect(authFailureReasonFromCode('weak-password'),
        AuthFailureReason.weakPassword);
    expect(authFailureReasonFromCode('too-many-requests'),
        AuthFailureReason.tooManyRequests);
    expect(authFailureReasonFromCode('network-request-failed'),
        AuthFailureReason.network);
    expect(authFailureReasonFromCode('account-exists-with-different-credential'),
        AuthFailureReason.accountExistsWithOtherMethod);
    expect(authFailureReasonFromCode('user-disabled'),
        AuthFailureReason.userDisabled);
    expect(authFailureReasonFromCode(googleSignInFailedCode),
        AuthFailureReason.googleSignInFailed);
  });

  test('un code inconnu donne unknown', () {
    expect(authFailureReasonFromCode('quota-exceeded'),
        AuthFailureReason.unknown);
  });
}
