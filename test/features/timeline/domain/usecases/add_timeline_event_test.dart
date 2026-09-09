// ============================================================================
// TEST UNITAIRE : AddTimelineEvent (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';
import 'package:amor_app/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/add_timeline_event.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late MockTimelineRepository mockRepository;
  late AddTimelineEvent useCase;

  final tEvent = TimelineEventEntity(
    id: '',
    title: 'Notre premier voyage',
    date: DateTime(2024, 6, 15),
    place: 'Paris',
    who: 'Lulu',
    imageUrl: '',
    description: 'Un super souvenir',
  );

  setUp(() {
    mockRepository = MockTimelineRepository();
    useCase = AddTimelineEvent(mockRepository);
  });

  test(
      'doit appeler repository.addEvent avec l\'événement fourni et renvoyer '
      'l\'id généré', () async {
    when(() => mockRepository.addEvent(tEvent))
        .thenAnswer((_) async => 'generated_id_123');

    final result = await useCase(tEvent);

    expect(result, 'generated_id_123');
    verify(() => mockRepository.addEvent(tEvent)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('doit laisser remonter l\'exception si le repository échoue',
      () async {
    when(() => mockRepository.addEvent(tEvent))
        .thenThrow(Exception('Firestore indisponible'));

    expect(() => useCase(tEvent), throwsException);
  });
}
