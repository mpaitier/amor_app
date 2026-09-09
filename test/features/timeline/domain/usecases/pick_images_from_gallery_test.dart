// ============================================================================
// TEST UNITAIRE : PickImagesFromGallery (use case)
// ============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/domain/repositories/image_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/pick_images_from_gallery.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  late MockImageRepository mockRepository;
  late PickImagesFromGallery useCase;

  setUp(() {
    mockRepository = MockImageRepository();
    useCase = PickImagesFromGallery(mockRepository);
  });

  test('doit renvoyer les fichiers sélectionnés par le repository',
      () async {
    final files = [File('a.jpg'), File('b.jpg')];
    when(() => mockRepository.pickMultipleFromGallery())
        .thenAnswer((_) async => files);

    final result = await useCase();

    expect(result, files);
    verify(() => mockRepository.pickMultipleFromGallery()).called(1);
  });

  test('doit renvoyer une liste vide si aucune image n\'est sélectionnée',
      () async {
    when(() => mockRepository.pickMultipleFromGallery())
        .thenAnswer((_) async => []);

    final result = await useCase();

    expect(result, isEmpty);
  });
}
