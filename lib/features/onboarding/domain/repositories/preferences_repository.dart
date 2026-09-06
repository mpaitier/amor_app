// ============================================================================
// PREFERENCES REPOSITORY (INTERFACE)
// ============================================================================

abstract class PreferencesRepository {
  Future<bool> isFirstRun();
  Future<void> setFirstRunCompleted();
}