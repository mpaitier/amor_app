// ============================================================================
// PREFERENCES REPOSITORY (IMPLEMENTATION)
// ============================================================================

import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_local_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesLocalDataSource _localDataSource;

  const PreferencesRepositoryImpl({
    required PreferencesLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<bool> isFirstRun() => _localDataSource.isFirstRun();

  @override
  Future<void> setFirstRunCompleted() =>
      _localDataSource.setFirstRunCompleted();
}