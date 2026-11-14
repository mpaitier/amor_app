// ============================================================================
// AUTH FAILURE (ENTITY)
// ============================================================================
// Échec de connexion ou d'inscription, exprimé sans vocabulaire Firebase.
// Le repository traduit les codes Firebase vers ces raisons, la
// présentation les traduit en phrases.

enum AuthFailureReason {
  invalidEmail,
  wrongCredentials,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  network,
  accountExistsWithOtherMethod,
  userDisabled,
  googleSignInFailed,
  unknown,
}

class AuthFailure implements Exception {
  final AuthFailureReason reason;

  const AuthFailure(this.reason);

  @override
  String toString() => 'AuthFailure(${reason.name})';
}
