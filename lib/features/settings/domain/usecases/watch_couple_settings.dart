// ============================================================================
// USE CASE: WATCH COUPLE SETTINGS
// ============================================================================

import '../entities/couple_settings_entity.dart';
import '../repositories/couple_settings_repository.dart';

class WatchCoupleSettings {
  final CoupleSettingsRepository _repository;
  const WatchCoupleSettings(this._repository);

  Stream<CoupleSettingsEntity> call() => _repository.watchSettings();
}
