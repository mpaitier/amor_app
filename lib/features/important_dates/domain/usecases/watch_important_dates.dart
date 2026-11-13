// ============================================================================
// USE CASE: WATCH IMPORTANT DATES
// ============================================================================

import '../entities/important_date_entity.dart';
import '../repositories/important_date_repository.dart';

class WatchImportantDates {
  final ImportantDateRepository _repository;
  const WatchImportantDates(this._repository);

  Stream<List<ImportantDateEntity>> call() {
    return _repository.watchImportantDates();
  }
}
