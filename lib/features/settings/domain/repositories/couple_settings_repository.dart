// ============================================================================
// COUPLE SETTINGS REPOSITORY (INTERFACE)
// ============================================================================

import '../entities/couple_settings_entity.dart';

abstract class CoupleSettingsRepository {
  // --- Flux temps réel des réglages. Émet les réglages d'origine tant
  // --- que rien n'a été enregistré ---
  Stream<CoupleSettingsEntity> watchSettings();

  // --- Enregistre les réglages ---
  Future<void> saveSettings(CoupleSettingsEntity settings);
}
