// ============================================================================
// USE CASE : DELETE ACCOUNT
// ============================================================================
// Supprime définitivement le compte. Les souvenirs créés restent pour les
// autres membres de la relation ; si la personne était seule, la relation
// est supprimée avec elle.

import '../repositories/auth_repository.dart';

class DeleteAccount {
  final AuthRepository _repository;

  const DeleteAccount(this._repository);

  Future<void> call() => _repository.deleteAccount();
}
