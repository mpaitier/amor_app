// ============================================================================
// TEST UNITAIRE : SearchPlaces (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/place/domain/entities/place_prediction_entity.dart';
import 'package:amor_app/features/place/domain/repositories/place_repository.dart';
import 'package:amor_app/features/place/domain/usecases/search_places.dart';

class MockPlaceRepository extends Mock implements PlaceRepository {}

void main() {
  late MockPlaceRepository mockRepository;
  late SearchPlaces useCase;

  setUp(() {
    mockRepository = MockPlaceRepository();
    useCase = SearchPlaces(mockRepository);
  });

  test('doit renvoyer les prédictions du repository pour la requête donnée',
      () async {
    final predictions = [
      const PlacePredictionEntity(description: 'Paris, France'),
    ];
    when(() => mockRepository.searchPlaces('Par'))
        .thenAnswer((_) async => predictions);

    final result = await useCase('Par');

    expect(result, predictions);
    verify(() => mockRepository.searchPlaces('Par')).called(1);
  });

  test('doit renvoyer une liste vide si aucun lieu ne correspond', () async {
    when(() => mockRepository.searchPlaces('xyz123'))
        .thenAnswer((_) async => []);

    final result = await useCase('xyz123');

    expect(result, isEmpty);
  });
}
