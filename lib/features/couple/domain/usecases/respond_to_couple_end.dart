// ============================================================================
// USE CASE : RESPOND TO COUPLE END
// ============================================================================
// Accepte ou refuse la demande d'arrêt. Renvoie true si cette réponse était
// la dernière attendue et que la relation a été supprimée.

import '../repositories/couple_repository.dart';

class RespondToCoupleEnd {
  final CoupleRepository _repository;

  const RespondToCoupleEnd(this._repository);

  Future<bool> call({required bool accept}) {
    return _repository.respondToEnd(accept: accept);
  }
}
