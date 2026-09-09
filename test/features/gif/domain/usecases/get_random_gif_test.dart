// ============================================================================
// TEST UNITAIRE : GetRandomGif (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/gif/domain/repositories/gif_repository.dart';
import 'package:amor_app/features/gif/domain/usecases/get_random_gif.dart';

class MockGifRepository extends Mock implements GifRepository {}

void main() {
  late MockGifRepository mockRepository;
  late GetRandomGif useCase;

  setUp(() {
    mockRepository = MockGifRepository();
    useCase = GetRandomGif(mockRepository);
  });

  test('doit renvoyer l\'url fournie par le repository', () async {
    when(() => mockRepository.getRandomGifUrl('love'))
        .thenAnswer((_) async => 'https://giphy.com/abc.gif');

    final result = await useCase('love');

    expect(result, 'https://giphy.com/abc.gif');
    verify(() => mockRepository.getRandomGifUrl('love')).called(1);
  });

  test('doit renvoyer null si aucun gif n\'est trouvé', () async {
    when(() => mockRepository.getRandomGifUrl('xyz'))
        .thenAnswer((_) async => null);

    final result = await useCase('xyz');

    expect(result, isNull);
  });
}
