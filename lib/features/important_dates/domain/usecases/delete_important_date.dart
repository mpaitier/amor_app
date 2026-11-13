// ============================================================================
// USE CASE: DELETE IMPORTANT DATE
// ============================================================================

import '../repositories/important_date_repository.dart';

class DeleteImportantDate {
  final ImportantDateRepository _repository;
  const DeleteImportantDate(this._repository);

  Future<void> call(String dateId) {
    return _repository.deleteImportantDate(dateId);
  }
}
