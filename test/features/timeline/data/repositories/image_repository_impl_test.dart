// ============================================================================
// TEST UNITAIRE : ImageRepositoryImpl
// ============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/data/datasources/image_local_datasource.dart';
import 'package:amor_app/features/timeline/data/datasources/image_remote_datasource.dart';
import 'package:amor_app/features/timeline/data/repositories/image_repository_impl.dart';

class MockImageLocalDataSource extends Mock implements ImageLocalDataSource {}

class MockImageRemoteDataSource extends Mock
    implements ImageRemoteDataSource {}

void main() {
  late MockImageLocalDataSource mockLocal;
  late MockImageRemoteDataSource mockRemote;
  late ImageRepositoryImpl repository;

  setUp(() {
    mockLocal = MockImageLocalDataSource();
    mockRemote = MockImageRemoteDataSource();
    repository = ImageRepositoryImpl(
      localDataSource: mockLocal,
      remoteDataSource: mockRemote,
    );
  });

  test('pickMultipleFromGallery doit déléguer à la source locale', () async {
    final files = [File('a.jpg'), File('b.jpg')];
    when(() => mockLocal.pickMultipleFromGallery())
        .thenAnswer((_) async => files);

    final result = await repository.pickMultipleFromGallery();

    expect(result, files);
  });

  test('takePhoto doit déléguer à la source locale', () async {
    final file = File('photo.jpg');
    when(() => mockLocal.takePhoto()).thenAnswer((_) async => file);

    final result = await repository.takePhoto();

    expect(result, file);
  });

  test('uploadImage doit déléguer à la source distante avec le bon dossier',
      () async {
    final file = File('img.jpg');
    when(() => mockRemote.uploadImage(
          imageFile: file,
          folder: 'amor_events/paris',
        )).thenAnswer((_) async => 'https://storage/img.jpg');

    final url = await repository.uploadImage(
      imageFile: file,
      folder: 'amor_events/paris',
    );

    expect(url, 'https://storage/img.jpg');
  });

  test('uploadImages doit déléguer à la source distante pour un batch',
      () async {
    final files = [File('a.jpg'), File('b.jpg')];
    when(() => mockRemote.uploadImages(
          imageFiles: files,
          folder: 'amor_events/paris',
        )).thenAnswer((_) async => ['url_a', 'url_b']);

    final result = await repository.uploadImages(
      imageFiles: files,
      folder: 'amor_events/paris',
    );

    expect(result, ['url_a', 'url_b']);
  });

  test('deleteImage doit déléguer à la source distante', () async {
    when(() => mockRemote.deleteImage('https://storage/img.jpg'))
        .thenAnswer((_) async {});

    await repository.deleteImage('https://storage/img.jpg');

    verify(() => mockRemote.deleteImage('https://storage/img.jpg'))
        .called(1);
  });
}
