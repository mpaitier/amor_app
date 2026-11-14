// ============================================================================
// COUPLE REPOSITORY (IMPLEMENTATION)
// ============================================================================
// Délègue à la data source et convertit chaque CoupleException en
// CoupleFailure du domaine.

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/couple_entity.dart';
import '../../domain/entities/couple_failure.dart';
import '../../domain/repositories/couple_repository.dart';
import '../datasources/couple_remote_datasource.dart';
import '../mappers/couple_failure_mapper.dart';

class CoupleRepositoryImpl implements CoupleRepository {
  final CoupleRemoteDataSource _remoteDataSource;

  const CoupleRepositoryImpl({required CoupleRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Stream<CoupleEntity?> watchCurrentCouple(String uid) {
    return _remoteDataSource.watchCurrentCouple(uid);
  }

  @override
  Future<String> createCouple({required String nickname, required int color}) {
    return _guard(
      () => _remoteDataSource.createCouple(nickname: nickname, color: color),
    );
  }

  @override
  Future<String> joinCouple({
    required String code,
    required String nickname,
    required int color,
  }) {
    return _guard(
      () => _remoteDataSource.joinCouple(
        code: code,
        nickname: nickname,
        color: color,
      ),
    );
  }

  @override
  Future<void> updateMemberProfile({
    required String coupleId,
    required String uid,
    required String nickname,
    required int color,
  }) {
    return _guard(
      () => _remoteDataSource.updateMemberProfile(
        coupleId: coupleId,
        uid: uid,
        nickname: nickname,
        color: color,
      ),
    );
  }

  // --- Traduction des erreurs de la data source ---
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CoupleException catch (e) {
      throw CoupleFailure(coupleFailureReasonFromCode(e.code));
    }
  }
}
