// ============================================================================
// USE CASE: GET RECENT COLORS
// ============================================================================

import '../entities/color_history_kind.dart';
import '../repositories/color_history_repository.dart';

class GetRecentColors {
  final ColorHistoryRepository _repository;
  const GetRecentColors(this._repository);

  Future<List<int>> call(ColorHistoryKind kind) {
    return _repository.getRecentColors(kind);
  }
}
