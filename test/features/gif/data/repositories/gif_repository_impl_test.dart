// ============================================================================
// TEST UNITAIRE : GifRepositoryImpl
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/gif/data/datasources/gif_remote_datasource.dart';
import 'package:amor_app/features/gif/data/repositories/gif_repository_impl.dart';

class MockGifRemoteDataSource extends Mock implements GifRemoteDataSource {}

void main() {
  late MockGifRemoteDataSource mockDataSource;
  late GifRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockGifRemoteDataSource();
    repository = GifRepositoryImpl(remoteDataSource: mockDataSource);
  });

  test('getRandomGifUrl doit déléguer à la source distante', () async {
    when(() => mockDataSource.fetchRandomGifUrl('cute'))
        .thenAnswer((_) async => 'https://giphy.com/x.gif');

    final result = await repository.getRandomGifUrl('cute');

    expect(result, 'https://giphy.com/x.gif');
    verify(() => mockDataSource.fetchRandomGifUrl('cute')).called(1);
  });

  test('getRandomGifUrl doit renvoyer null si la source n\'a rien trouvé',
      () async {
    when(() => mockDataSource.fetchRandomGifUrl('inconnu'))
        .thenAnswer((_) async => null);

    final result = await repository.getRandomGifUrl('inconnu');

    expect(result, isNull);
  });
}
