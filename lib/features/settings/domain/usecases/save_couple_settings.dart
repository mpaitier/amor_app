// ============================================================================
// USE CASE: SAVE COUPLE SETTINGS
// ============================================================================

import '../entities/couple_settings_entity.dart';
import '../repositories/couple_settings_repository.dart';

class SaveCoupleSettings {
  final CoupleSettingsRepository _repository;
  const SaveCoupleSettings(this._repository);

  Future<void> call(CoupleSettingsEntity settings) {
    return _repository.saveSettings(settings);
  }
}
