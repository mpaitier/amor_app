// ============================================================================
// PLACE REPOSITORY (INTERFACE)
// ============================================================================

import '../entities/place_prediction_entity.dart';

abstract class PlaceRepository {
  Future<List<PlacePredictionEntity>> searchPlaces(String query);
}