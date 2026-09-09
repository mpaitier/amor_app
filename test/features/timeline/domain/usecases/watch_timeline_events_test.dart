// ============================================================================
// TEST UNITAIRE : WatchTimelineEvents (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';
import 'package:amor_app/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/watch_timeline_events.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late MockTimelineRepository mockRepository;
  late WatchTimelineEvents useCase;

  setUp(() {
    mockRepository = MockTimelineRepository();
    useCase = WatchTimelineEvents(mockRepository);
  });

  test('doit relayer le flux d\'événements exposé par le repository',
      () async {
    final events = [
      TimelineEventEntity(
        id: '1',
        title: 'Souvenir 1',
        date: DateTime(2024, 1, 1),
        place: 'Paris',
        who: 'Lulu',
        imageUrl: '',
        description: '',
      ),
      TimelineEventEntity(
        id: '2',
        title: 'Souvenir 2',
        date: DateTime(2024, 2, 1),
        place: 'Lyon',
        who: 'Titi',
        imageUrl: '',
        description: '',
      ),
    ];
    when(() => mockRepository.watchEvents())
        .thenAnswer((_) => Stream.value(events));

    final result = await useCase().first;

    expect(result, events);
    verify(() => mockRepository.watchEvents()).called(1);
  });

  test('doit relayer les erreurs émises par le flux du repository', () async {
    when(() => mockRepository.watchEvents())
        .thenAnswer((_) => Stream.error(Exception('Erreur réseau')));

    expect(useCase(), emitsError(isA<Exception>()));
  });
}
