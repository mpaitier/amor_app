// ============================================================================
// TEST UNITAIRE : TimelineRepositoryImpl
// ============================================================================
// Vérifie la conversion Entity <-> Model et la délégation vers la
// datasource distante (Firestore mocké).

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/timeline/data/datasources/timeline_remote_datasource.dart';
import 'package:amor_app/features/timeline/data/models/timeline_event_model.dart';
import 'package:amor_app/features/timeline/data/repositories/timeline_repository_impl.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';

class MockTimelineRemoteDataSource extends Mock
    implements TimelineRemoteDataSource {}

// --- Fake utilisé uniquement pour enregistrer une valeur de repli auprès
// --- de mocktail (nécessaire pour matcher any() sur un type non natif) ---
class _FakeTimelineEventModel extends Fake implements TimelineEventModel {}

void main() {
  late MockTimelineRemoteDataSource mockDataSource;
  late TimelineRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeTimelineEventModel());
  });

  setUp(() {
    mockDataSource = MockTimelineRemoteDataSource();
    repository = TimelineRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final tEntity = TimelineEventEntity(
    id: 'event_1',
    title: 'Anniversaire',
    date: DateTime(2024, 3, 10),
    place: 'Lyon',
    who: 'Titi',
    imageUrl: 'url1',
    description: 'Super soirée',
  );

  test('watchEvents doit relayer le flux de modèles en tant qu\'entités',
      () async {
    final model = TimelineEventModel.fromEntity(tEntity);
    when(() => mockDataSource.watchEvents())
        .thenAnswer((_) => Stream.value([model]));

    final result = await repository.watchEvents().first;

    expect(result, hasLength(1));
    expect(result.first.title, 'Anniversaire');
    expect(result.first.place, 'Lyon');
  });

  test('addEvent doit convertir l\'entité en modèle avant l\'envoi', () async {
    when(() => mockDataSource.addEvent(any()))
        .thenAnswer((_) async => 'new_id');

    final id = await repository.addEvent(tEntity);

    expect(id, 'new_id');
    final captured =
        verify(() => mockDataSource.addEvent(captureAny())).captured.single
            as TimelineEventModel;
    expect(captured.title, tEntity.title);
    expect(captured.place, tEntity.place);
    expect(captured.description, tEntity.description);
  });

  test('updateEvent doit convertir l\'entité en modèle avant l\'envoi',
      () async {
    when(() => mockDataSource.updateEvent(any())).thenAnswer((_) async {});

    await repository.updateEvent(tEntity);

    final captured =
        verify(() => mockDataSource.updateEvent(captureAny())).captured.single
            as TimelineEventModel;
    expect(captured.id, tEntity.id);
    expect(captured.who, tEntity.who);
  });

  test('deleteEvent doit déléguer directement l\'id à la source distante',
      () async {
    when(() => mockDataSource.deleteEvent('event_1'))
        .thenAnswer((_) async {});

    await repository.deleteEvent('event_1');

    verify(() => mockDataSource.deleteEvent('event_1')).called(1);
  });
}
