// ============================================================================
// IMPORTANT DATE REPOSITORY (IMPLEMENTATION)
// ============================================================================
// Implémente le contrat du domaine au-dessus de la datasource Firestore.

import '../../domain/entities/important_date_entity.dart';
import '../../domain/repositories/important_date_repository.dart';
import '../datasources/important_date_remote_datasource.dart';
import '../models/important_date_model.dart';

class ImportantDateRepositoryImpl implements ImportantDateRepository {
  final ImportantDateRemoteDataSource _remoteDataSource;

  const ImportantDateRepositoryImpl({
    required ImportantDateRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<List<ImportantDateEntity>> watchImportantDates() {
    return _remoteDataSource.watchImportantDates();
  }

  @override
  Future<String> addImportantDate(ImportantDateEntity date) {
    return _remoteDataSource
        .addImportantDate(ImportantDateModel.fromEntity(date));
  }

  @override
  Future<void> updateImportantDate(ImportantDateEntity date) {
    return _remoteDataSource
        .updateImportantDate(ImportantDateModel.fromEntity(date));
  }

  @override
  Future<void> deleteImportantDate(String dateId) {
    return _remoteDataSource.deleteImportantDate(dateId);
  }
}
