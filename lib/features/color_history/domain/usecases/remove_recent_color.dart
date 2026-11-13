// ============================================================================
// USE CASE: REMOVE RECENT COLOR
// ============================================================================

import '../entities/color_history_kind.dart';
import '../repositories/color_history_repository.dart';

class RemoveRecentColor {
  final ColorHistoryRepository _repository;
  const RemoveRecentColor(this._repository);

  Future<List<int>> call(ColorHistoryKind kind, int color) {
    return _repository.removeRecentColor(kind, color);
  }
}
