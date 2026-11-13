// ============================================================================
// TEST UNITAIRE : UpdateImportantDate (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';
import 'package:amor_app/features/important_dates/domain/repositories/important_date_repository.dart';
import 'package:amor_app/features/important_dates/domain/usecases/update_important_date.dart';

class MockImportantDateRepository extends Mock
    implements ImportantDateRepository {}

void main() {
  late MockImportantDateRepository mockRepository;
  late UpdateImportantDate useCase;

  final tDate = ImportantDateEntity(
    id: 'date_42',
    title: 'Départ à Lisbonne',
    date: DateTime(2026, 12, 28),
    emoji: '✈️',
    repeatsYearly: false,
  );

  setUp(() {
    mockRepository = MockImportantDateRepository();
    useCase = UpdateImportantDate(mockRepository);
  });

  test('doit appeler repository.updateImportantDate avec la date fournie',
      () async {
    when(() => mockRepository.updateImportantDate(tDate))
        .thenAnswer((_) async {});

    await useCase(tDate);

    verify(() => mockRepository.updateImportantDate(tDate)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('doit laisser remonter l\'exception si le repository échoue',
      () async {
    when(() => mockRepository.updateImportantDate(tDate))
        .thenThrow(Exception('Firestore indisponible'));

    expect(() => useCase(tDate), throwsException);
  });
}
