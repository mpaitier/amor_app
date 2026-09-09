// ============================================================================
// TEST UNITAIRE : UpdateTimelineEvent (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';
import 'package:amor_app/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/update_timeline_event.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late MockTimelineRepository mockRepository;
  late UpdateTimelineEvent useCase;

  final tEvent = TimelineEventEntity(
    id: 'event_1',
    title: 'Anniversaire',
    date: DateTime(2024, 3, 10),
    place: 'Lyon',
    who: 'Titi',
    imageUrl: 'url1',
    description: 'Super soirée',
  );

  setUp(() {
    mockRepository = MockTimelineRepository();
    useCase = UpdateTimelineEvent(mockRepository);
  });

  test('doit appeler repository.updateEvent avec l\'événement fourni',
      () async {
    when(() => mockRepository.updateEvent(tEvent)).thenAnswer((_) async {});

    await useCase(tEvent);

    verify(() => mockRepository.updateEvent(tEvent)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('doit laisser remonter l\'exception si le repository échoue',
      () async {
    when(() => mockRepository.updateEvent(tEvent))
        .thenThrow(Exception('Firestore indisponible'));

    expect(() => useCase(tEvent), throwsException);
  });
}
