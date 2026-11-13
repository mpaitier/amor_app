// ============================================================================
// USE CASE: ADD IMPORTANT DATE
// ============================================================================

import '../entities/important_date_entity.dart';
import '../repositories/important_date_repository.dart';

class AddImportantDate {
  final ImportantDateRepository _repository;
  const AddImportantDate(this._repository);

  Future<String> call(ImportantDateEntity date) {
    return _repository.addImportantDate(date);
  }
}
