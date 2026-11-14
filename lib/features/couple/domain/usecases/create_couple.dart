// ============================================================================
// USE CASE : CREATE COUPLE
// ============================================================================
// Crée la relation avec la personne connectée comme premier membre, et
// enregistre le jour où l'histoire a commencé (sans l'heure).

import '../entities/couple_failure.dart';
import '../repositories/couple_repository.dart';

class CreateCouple {
  final CoupleRepository _repository;

  const CreateCouple(this._repository);

  Future<String> call({
    required String nickname,
    required int color,
    required DateTime relationshipStart,
  }) async {
    final cleanNickname = nickname.trim();
    if (cleanNickname.isEmpty) {
      throw const CoupleFailure(CoupleFailureReason.invalidProfile);
    }
    return _repository.createCouple(
      nickname: cleanNickname,
      color: color,
      relationshipStart: DateTime(
        relationshipStart.year,
        relationshipStart.month,
        relationshipStart.day,
      ),
    );
  }
}
