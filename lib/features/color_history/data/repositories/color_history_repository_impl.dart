// ============================================================================
// COLOR HISTORY REPOSITORY (IMPLEMENTATION)
// ============================================================================

import '../../domain/entities/color_history_kind.dart';
import '../../domain/repositories/color_history_repository.dart';
import '../datasources/color_history_local_datasource.dart';

class ColorHistoryRepositoryImpl implements ColorHistoryRepository {
  final ColorHistoryLocalDataSource _localDataSource;

  const ColorHistoryRepositoryImpl({
    required ColorHistoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<int>> getRecentColors(ColorHistoryKind kind) {
    return _localDataSource.getRecentColors(kind);
  }

  @override
  Future<List<int>> addRecentColor(ColorHistoryKind kind, int color) {
    return _localDataSource.addRecentColor(kind, color);
  }
}
