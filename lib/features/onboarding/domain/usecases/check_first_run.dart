// ============================================================================
// USE CASE: CHECK FIRST RUN
// ============================================================================

import '../repositories/preferences_repository.dart';

class CheckFirstRun {
  final PreferencesRepository _repository;
  const CheckFirstRun(this._repository);

  Future<bool> call() => _repository.isFirstRun();
}