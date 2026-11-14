// ============================================================================
// AUTH FAILURE MAPPER
// ============================================================================
// Traduit les codes d'erreur Firebase Auth en raisons du domaine. Depuis
// la protection contre l'énumération des e-mails, Firebase renvoie souvent
// "invalid-credential" au lieu de "user-not-found" ou "wrong-password" :
// les trois mènent au même message.

import '../../domain/entities/auth_failure.dart';

// --- Code propre à l'app, levé quand Google Sign-In échoue côté appareil ---
const String googleSignInFailedCode = 'google-sign-in-failed';

AuthFailureReason authFailureReasonFromCode(String code) {
  switch (code) {
    case 'invalid-email':
      return AuthFailureReason.invalidEmail;
    case 'invalid-credential':
    case 'user-not-found':
    case 'wrong-password':
    case 'INVALID_LOGIN_CREDENTIALS':
      return AuthFailureReason.wrongCredentials;
    case 'email-already-in-use':
      return AuthFailureReason.emailAlreadyInUse;
    case 'weak-password':
      return AuthFailureReason.weakPassword;
    case 'too-many-requests':
      return AuthFailureReason.tooManyRequests;
    case 'network-request-failed':
      return AuthFailureReason.network;
    case 'account-exists-with-different-credential':
      return AuthFailureReason.accountExistsWithOtherMethod;
    case 'user-disabled':
      return AuthFailureReason.userDisabled;
    case googleSignInFailedCode:
      return AuthFailureReason.googleSignInFailed;
    default:
      return AuthFailureReason.unknown;
  }
}
