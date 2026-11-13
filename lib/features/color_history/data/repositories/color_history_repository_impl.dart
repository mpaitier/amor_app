// ============================================================================
// COLOR HISTORY REPOSITORY (IMPLEMENTATION)
// ============================================================================

import '../../domain/repositories/color_history_repository.dart';
import '../datasources/color_history_local_datasource.dart';

class ColorHistoryRepositoryImpl implements ColorHistoryRepository {
  final ColorHistoryLocalDataSource _localDataSource;

  const ColorHistoryRepositoryImpl({
    required ColorHistoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<int>> getRecentColors() => _localDataSource.getRecentColors();

  @override
  Future<List<int>> addRecentColor(int color) {
    return _localDataSource.addRecentColor(color);
  }
}
