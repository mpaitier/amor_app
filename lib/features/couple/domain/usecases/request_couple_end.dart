// ============================================================================
// USE CASE : REQUEST COUPLE END
// ============================================================================
// Demande l'arrêt de la relation. Les autres membres sont prévenus et
// doivent tous accepter. Renvoie true si la relation a été supprimée
// aussitôt (personne seule dans la relation).

import '../repositories/couple_repository.dart';

class RequestCoupleEnd {
  final CoupleRepository _repository;

  const RequestCoupleEnd(this._repository);

  Future<bool> call() => _repository.requestEnd();
}
