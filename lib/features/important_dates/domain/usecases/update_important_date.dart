// ============================================================================
// USE CASE: UPDATE IMPORTANT DATE
// ============================================================================

import '../entities/important_date_entity.dart';
import '../repositories/important_date_repository.dart';

class UpdateImportantDate {
  final ImportantDateRepository _repository;
  const UpdateImportantDate(this._repository);

  Future<void> call(ImportantDateEntity date) {
    return _repository.updateImportantDate(date);
  }
}
