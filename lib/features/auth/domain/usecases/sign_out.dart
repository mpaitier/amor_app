// ============================================================================
// USE CASE : SIGN OUT
// ============================================================================
// Se déconnecter ne fait pas quitter la relation : les données restent et
// la personne les retrouve en se reconnectant.

import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository _repository;

  const SignOut(this._repository);

  Future<void> call() => _repository.signOut();
}
