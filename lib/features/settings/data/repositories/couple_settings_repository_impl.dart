// ============================================================================
// COUPLE SETTINGS REPOSITORY (IMPLEMENTATION)
// ============================================================================

import '../../domain/entities/couple_settings_entity.dart';
import '../../domain/repositories/couple_settings_repository.dart';
import '../datasources/couple_settings_remote_datasource.dart';
import '../models/couple_settings_model.dart';

class CoupleSettingsRepositoryImpl implements CoupleSettingsRepository {
  final CoupleSettingsRemoteDataSource _remoteDataSource;

  const CoupleSettingsRepositoryImpl({
    required CoupleSettingsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<CoupleSettingsEntity> watchSettings() {
    return _remoteDataSource.watchSettings();
  }

  @override
  Future<void> saveSettings(CoupleSettingsEntity settings) {
    return _remoteDataSource
        .saveSettings(CoupleSettingsModel.fromEntity(settings));
  }
}
