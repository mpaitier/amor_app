// ============================================================================
// TEST UNITAIRE : AddImportantDate (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';
import 'package:amor_app/features/important_dates/domain/repositories/important_date_repository.dart';
import 'package:amor_app/features/important_dates/domain/usecases/add_important_date.dart';

class MockImportantDateRepository extends Mock
    implements ImportantDateRepository {}

void main() {
  late MockImportantDateRepository mockRepository;
  late AddImportantDate useCase;

  final tDate = ImportantDateEntity(
    id: '',
    title: 'Départ à Lisbonne',
    date: DateTime(2026, 12, 28),
    emoji: '✈️',
    recurrence: ImportantDateRecurrence.none,
  );

  setUp(() {
    mockRepository = MockImportantDateRepository();
    useCase = AddImportantDate(mockRepository);
  });

  test(
      'doit appeler repository.addImportantDate avec la date fournie et '
      'renvoyer l\'id généré', () async {
    when(() => mockRepository.addImportantDate(tDate))
        .thenAnswer((_) async => 'generated_id_123');

    final result = await useCase(tDate);

    expect(result, 'generated_id_123');
    verify(() => mockRepository.addImportantDate(tDate)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('doit laisser remonter l\'exception si le repository échoue',
      () async {
    when(() => mockRepository.addImportantDate(tDate))
        .thenThrow(Exception('Firestore indisponible'));

    expect(() => useCase(tDate), throwsException);
  });
}
