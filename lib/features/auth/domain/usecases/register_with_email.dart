// ============================================================================
// USE CASE : REGISTER WITH EMAIL
// ============================================================================
// Crée le compte et connecte aussitôt la personne.

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmail {
  final AuthRepository _repository;

  const RegisterWithEmail(this._repository);

  Future<AppUser> call({
    required String email,
    required String password,
  }) {
    return _repository.registerWithEmail(
      email: email.trim(),
      password: password,
    );
  }
}
