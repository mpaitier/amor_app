// ============================================================================
// USE CASE : WATCH CURRENT COUPLE
// ============================================================================

import '../entities/couple_entity.dart';
import '../repositories/couple_repository.dart';

class WatchCurrentCouple {
  final CoupleRepository _repository;

  const WatchCurrentCouple(this._repository);

  Stream<CoupleEntity?> call(String uid) => _repository.watchCurrentCouple(uid);
}
