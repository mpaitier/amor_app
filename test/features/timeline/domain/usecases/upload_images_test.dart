// ============================================================================
// TEST UNITAIRE : UploadImages (use case)
// ============================================================================
// Couvre les deux méthodes exposées : uploadSingle() et call() (batch).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/domain/repositories/image_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/upload_images.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  late MockImageRepository mockRepository;
  late UploadImages useCase;

  setUp(() {
    mockRepository = MockImageRepository();
    useCase = UploadImages(mockRepository);
  });

  group('uploadSingle', () {
    test('doit déléguer à repository.uploadImage et renvoyer l\'url',
        () async {
      final file = File('img.jpg');
      when(() => mockRepository.uploadImage(
            imageFile: file,
            folder: 'amor_events/paris',
          )).thenAnswer((_) async => 'https://storage/img.jpg');

      final url = await useCase.uploadSingle(
        imageFile: file,
        folder: 'amor_events/paris',
      );

      expect(url, 'https://storage/img.jpg');
    });

    test('doit renvoyer null si l\'upload échoue silencieusement', () async {
      final file = File('img.jpg');
      when(() => mockRepository.uploadImage(
            imageFile: file,
            folder: 'amor_events/paris',
          )).thenAnswer((_) async => null);

      final url = await useCase.uploadSingle(
        imageFile: file,
        folder: 'amor_events/paris',
      );

      expect(url, isNull);
    });
  });

  group('call (batch)', () {
    test('doit déléguer à repository.uploadImages et renvoyer les urls',
        () async {
      final files = [File('a.jpg'), File('b.jpg')];
      when(() => mockRepository.uploadImages(
            imageFiles: files,
            folder: 'amor_events/paris',
          )).thenAnswer((_) async => ['url_a', 'url_b']);

      final urls =
          await useCase(imageFiles: files, folder: 'amor_events/paris');

      expect(urls, ['url_a', 'url_b']);
    });
  });
}
