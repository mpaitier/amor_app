// ============================================================================
// USE CASE : JOIN COUPLE
// ============================================================================
// Rejoint une relation par son code. Un code mal formé est refusé ici,
// sans appel réseau.

import '../entities/couple_failure.dart';
import '../repositories/couple_repository.dart';
import '../utils/invite_code.dart';

class JoinCouple {
  final CoupleRepository _repository;

  const JoinCouple(this._repository);

  Future<String> call({
    required String code,
    required String nickname,
    required int color,
  }) async {
    final cleanNickname = nickname.trim();
    if (cleanNickname.isEmpty) {
      throw const CoupleFailure(CoupleFailureReason.invalidProfile);
    }
    final cleanCode = normalizeInviteCode(code);
    if (cleanCode == null) {
      throw const CoupleFailure(CoupleFailureReason.invalidCode);
    }
    return _repository.joinCouple(
      code: cleanCode,
      nickname: cleanNickname,
      color: color,
    );
  }
}
