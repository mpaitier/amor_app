// ============================================================================
// TEST UNITAIRE : WatchImportantDates (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';
import 'package:amor_app/features/important_dates/domain/repositories/important_date_repository.dart';
import 'package:amor_app/features/important_dates/domain/usecases/watch_important_dates.dart';

class MockImportantDateRepository extends Mock
    implements ImportantDateRepository {}

void main() {
  late MockImportantDateRepository mockRepository;
  late WatchImportantDates useCase;

  setUp(() {
    mockRepository = MockImportantDateRepository();
    useCase = WatchImportantDates(mockRepository);
  });

  test('doit relayer le flux de dates exposé par le repository', () async {
    final dates = [
      ImportantDateEntity(
        id: '1',
        title: 'Noël',
        date: DateTime(2026, 12, 25),
        emoji: '🎄',
        repeatsYearly: true,
      ),
    ];
    when(() => mockRepository.watchImportantDates())
        .thenAnswer((_) => Stream.value(dates));

    final result = await useCase().first;

    expect(result, dates);
    verify(() => mockRepository.watchImportantDates()).called(1);
  });

  test('doit relayer les erreurs émises par le flux du repository', () async {
    when(() => mockRepository.watchImportantDates())
        .thenAnswer((_) => Stream.error(Exception('Erreur réseau')));

    expect(useCase(), emitsError(isA<Exception>()));
  });
}
