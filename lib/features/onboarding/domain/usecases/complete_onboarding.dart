// ============================================================================
// USE CASE: COMPLETE ONBOARDING
// ============================================================================

import '../repositories/preferences_repository.dart';

class CompleteOnboarding {
  final PreferencesRepository _repository;
  const CompleteOnboarding(this._repository);

  Future<void> call() => _repository.setFirstRunCompleted();
}