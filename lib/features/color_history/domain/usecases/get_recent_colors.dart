// ============================================================================
// USE CASE: GET RECENT COLORS
// ============================================================================

import '../repositories/color_history_repository.dart';

class GetRecentColors {
  final ColorHistoryRepository _repository;
  const GetRecentColors(this._repository);

  Future<List<int>> call() => _repository.getRecentColors();
}
