// ============================================================================
// USE CASE: ADD RECENT COLOR
// ============================================================================

import '../repositories/color_history_repository.dart';

class AddRecentColor {
  final ColorHistoryRepository _repository;
  const AddRecentColor(this._repository);

  Future<List<int>> call(int color) => _repository.addRecentColor(color);
}
