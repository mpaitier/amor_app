// ============================================================================
// USE CASE : SIGN IN WITH GOOGLE
// ============================================================================
// Renvoie null si la personne annule le choix du compte Google.

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository _repository;

  const SignInWithGoogle(this._repository);

  Future<AppUser?> call() => _repository.signInWithGoogle();
}
