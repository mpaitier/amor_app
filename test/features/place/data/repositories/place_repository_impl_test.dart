// ============================================================================
// TEST UNITAIRE : PlaceRepositoryImpl
// ============================================================================
// Ce repository contient de la vraie logique métier : reconstruction de la
// description à partir des champs bruts, filtrage des résultats vides et
// déduplication. On la teste directement avec une datasource mockée.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/place/data/datasources/place_remote_datasource.dart';
import 'package:amor_app/features/place/data/repositories/place_repository_impl.dart';

class MockPlaceRemoteDataSource extends Mock
    implements PlaceRemoteDataSource {}

void main() {
  late MockPlaceRemoteDataSource mockDataSource;
  late PlaceRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockPlaceRemoteDataSource();
    repository = PlaceRepositoryImpl(remoteDataSource: mockDataSource);
  });

  test('utilise le champ "formatted" quand il est présent', () async {
    when(() => mockDataSource.fetchPredictions('Tour Eiffel')).thenAnswer(
      (_) async => [
        {'formatted': 'Tour Eiffel, Paris, France'},
      ],
    );

    final result = await repository.searchPlaces('Tour Eiffel');

    expect(result.map((p) => p.description), ['Tour Eiffel, Paris, France']);
  });

  test(
      'reconstitue une description à partir de name/city/country si '
      '"formatted" est absent', () async {
    when(() => mockDataSource.fetchPredictions('Louvre')).thenAnswer(
      (_) async => [
        {'name': 'Musée du Louvre', 'city': 'Paris', 'country': 'France'},
      ],
    );

    final result = await repository.searchPlaces('Louvre');

    expect(result.single.description, 'Musée du Louvre, Paris, France');
  });

  test('ignore les champs manquants lors de la reconstitution manuelle',
      () async {
    when(() => mockDataSource.fetchPredictions('Louvre')).thenAnswer(
      (_) async => [
        {'name': 'Musée du Louvre', 'country': 'France'},
      ],
    );

    final result = await repository.searchPlaces('Louvre');

    expect(result.single.description, 'Musée du Louvre, France');
  });

  test('ignore les résultats sans description exploitable', () async {
    when(() => mockDataSource.fetchPredictions('???')).thenAnswer(
      (_) async => [<String, dynamic>{}],
    );

    final result = await repository.searchPlaces('???');

    expect(result, isEmpty);
  });

  test('déduplique les résultats ayant la même description', () async {
    when(() => mockDataSource.fetchPredictions('Paris')).thenAnswer(
      (_) async => [
        {'formatted': 'Paris, France'},
        {'formatted': 'Paris, France'},
        {'formatted': 'Paris, Texas, USA'},
      ],
    );

    final result = await repository.searchPlaces('Paris');

    expect(result.length, 2);
    expect(
      result.map((p) => p.description),
      ['Paris, France', 'Paris, Texas, USA'],
    );
  });

  test('renvoie une liste vide si la datasource ne trouve rien', () async {
    when(() => mockDataSource.fetchPredictions('xyz'))
        .thenAnswer((_) async => []);

    final result = await repository.searchPlaces('xyz');

    expect(result, isEmpty);
  });
}
