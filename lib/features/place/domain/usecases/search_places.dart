// ============================================================================
// USE CASE: SEARCH PLACES
// ============================================================================

import '../entities/place_prediction_entity.dart';
import '../repositories/place_repository.dart';

class SearchPlaces {
  final PlaceRepository _repository;
  const SearchPlaces(this._repository);

  Future<List<PlacePredictionEntity>> call(String query) {
    return _repository.searchPlaces(query);
  }
}