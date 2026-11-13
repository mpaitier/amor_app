// ============================================================================
// TEST UNITAIRE : DeleteImportantDate (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/important_dates/domain/repositories/important_date_repository.dart';
import 'package:amor_app/features/important_dates/domain/usecases/delete_important_date.dart';

class MockImportantDateRepository extends Mock
    implements ImportantDateRepository {}

void main() {
  late MockImportantDateRepository mockRepository;
  late DeleteImportantDate useCase;

  setUp(() {
    mockRepository = MockImportantDateRepository();
    useCase = DeleteImportantDate(mockRepository);
  });

  test('doit appeler repository.deleteImportantDate avec le bon id', () async {
    when(() => mockRepository.deleteImportantDate('date_42'))
        .thenAnswer((_) async {});

    await useCase('date_42');

    verify(() => mockRepository.deleteImportantDate('date_42')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('doit laisser remonter l\'exception si le repository échoue',
      () async {
    when(() => mockRepository.deleteImportantDate('date_42'))
        .thenThrow(Exception('Firestore indisponible'));

    expect(() => useCase('date_42'), throwsException);
  });
}
