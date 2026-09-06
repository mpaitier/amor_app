// ============================================================================
// PLACE REPOSITORY (IMPLEMENTATION)
// ============================================================================

import '../../domain/entities/place_prediction_entity.dart';
import '../../domain/repositories/place_repository.dart';
import '../datasources/place_remote_datasource.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource _remoteDataSource;

  const PlaceRepositoryImpl({required PlaceRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<PlacePredictionEntity>> searchPlaces(String query) async {
    final rawResults = await _remoteDataSource.fetchPredictions(query);

    final predictions = rawResults
        .map(_toPrediction)
        .where((p) => p.description.isNotEmpty)
        .toList();

    // --- Deduplicate by description ---
    final seen = <String>{};
    return predictions.where((p) => seen.add(p.description)).toList();
  }

  // --- Build a prediction from a Geoapify result ---
  PlacePredictionEntity _toPrediction(Map<String, dynamic> result) {
    // --- "formatted" is already a readable, localized full address ---
    final formatted = (result['formatted'] as String?)?.trim();
    if (formatted != null && formatted.isNotEmpty) {
      return PlacePredictionEntity(description: formatted);
    }

    // --- Manual fallback if "formatted" is absent ---
    final name = (result['name'] as String?)?.trim();
    final city = (result['city'] as String?)?.trim();
    final country = (result['country'] as String?)?.trim();

    final parts = [name, city, country]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();

    return PlacePredictionEntity(description: parts.join(', '));
  }
}