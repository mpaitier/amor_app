// ============================================================================
// USE CASE: ADD RECENT COLOR
// ============================================================================

import '../entities/color_history_kind.dart';
import '../repositories/color_history_repository.dart';

class AddRecentColor {
  final ColorHistoryRepository _repository;
  const AddRecentColor(this._repository);

  Future<List<int>> call(ColorHistoryKind kind, int color) {
    return _repository.addRecentColor(kind, color);
  }
}
