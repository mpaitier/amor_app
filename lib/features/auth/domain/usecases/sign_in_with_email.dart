// ============================================================================
// USE CASE : SIGN IN WITH EMAIL
// ============================================================================
// L'adresse est nettoyée des espaces avant l'envoi : un espace copié-collé
// suffit à faire échouer la connexion.

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository _repository;

  const SignInWithEmail(this._repository);

  Future<AppUser> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(
      email: email.trim(),
      password: password,
    );
  }
}
