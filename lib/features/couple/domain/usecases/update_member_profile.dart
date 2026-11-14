// ============================================================================
// USE CASE : UPDATE MEMBER PROFILE
// ============================================================================
// Change le surnom et la couleur de la personne connectée.

import '../entities/couple_failure.dart';
import '../repositories/couple_repository.dart';

class UpdateMemberProfile {
  final CoupleRepository _repository;

  const UpdateMemberProfile(this._repository);

  Future<void> call({
    required String coupleId,
    required String uid,
    required String nickname,
    required int color,
  }) async {
    final cleanNickname = nickname.trim();
    if (cleanNickname.isEmpty) {
      throw const CoupleFailure(CoupleFailureReason.invalidProfile);
    }
    await _repository.updateMemberProfile(
      coupleId: coupleId,
      uid: uid,
      nickname: cleanNickname,
      color: color,
    );
  }
}
