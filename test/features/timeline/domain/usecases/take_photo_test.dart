// ============================================================================
// TEST UNITAIRE : TakePhoto (use case)
// ============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/domain/repositories/image_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/take_photo.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  late MockImageRepository mockRepository;
  late TakePhoto useCase;

  setUp(() {
    mockRepository = MockImageRepository();
    useCase = TakePhoto(mockRepository);
  });

  test('doit renvoyer le fichier capturé par le repository', () async {
    final file = File('photo.jpg');
    when(() => mockRepository.takePhoto()).thenAnswer((_) async => file);

    final result = await useCase();

    expect(result, file);
    verify(() => mockRepository.takePhoto()).called(1);
  });

  test('doit renvoyer null si la capture est annulée', () async {
    when(() => mockRepository.takePhoto()).thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isNull);
  });
}
