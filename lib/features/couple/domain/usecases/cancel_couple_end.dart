// ============================================================================
// USE CASE : CANCEL COUPLE END
// ============================================================================
// Retire la demande d'arrêt. Réservé à la personne qui l'a faite.

import '../repositories/couple_repository.dart';

class CancelCoupleEnd {
  final CoupleRepository _repository;

  const CancelCoupleEnd(this._repository);

  Future<void> call() => _repository.cancelEnd();
}
