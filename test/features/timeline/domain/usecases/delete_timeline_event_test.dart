// ============================================================================
// TEST UNITAIRE : DeleteTimelineEvent (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/delete_timeline_event.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late MockTimelineRepository mockRepository;
  late DeleteTimelineEvent useCase;

  setUp(() {
    mockRepository = MockTimelineRepository();
    useCase = DeleteTimelineEvent(mockRepository);
  });

  test('doit appeler repository.deleteEvent avec le bon id', () async {
    when(() => mockRepository.deleteEvent('event_42'))
        .thenAnswer((_) async {});

    await useCase('event_42');

    verify(() => mockRepository.deleteEvent('event_42')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('doit laisser remonter l\'exception si le repository échoue',
      () async {
    when(() => mockRepository.deleteEvent('event_42'))
        .thenThrow(Exception('Firestore indisponible'));

    expect(() => useCase('event_42'), throwsException);
  });
}
