// ============================================================================
// USE CASE : SEND PASSWORD RESET
// ============================================================================
// Firebase envoie un e-mail avec un lien pour choisir un nouveau mot de passe.

import '../repositories/auth_repository.dart';

class SendPasswordReset {
  final AuthRepository _repository;

  const SendPasswordReset(this._repository);

  Future<void> call(String email) => _repository.sendPasswordReset(email.trim());
}
