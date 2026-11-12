// ============================================================================
// TEST UNITAIRE : GroupEventsByDay (use case, logique pure)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/calendar/domain/usecases/group_events_by_day.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';

void main() {
  const useCase = GroupEventsByDay();

  TimelineEventEntity buildEvent(String id, DateTime date) {
    return TimelineEventEntity(
      id: id,
      title: 'Souvenir $id',
      date: date,
      place: 'Nantes',
      who: 'Lulu',
      imageUrl: '',
      description: '',
    );
  }

  test('doit renvoyer une map vide quand il n\'y a aucun souvenir', () {
    expect(useCase([]), isEmpty);
  });

  test('doit ranger un souvenir sous son jour, sans tenir compte de l\'heure',
      () {
    final event = buildEvent('1', DateTime(2026, 10, 3, 18, 45));

    final result = useCase([event]);

    expect(result.keys, [DateTime(2026, 10, 3)]);
    expect(result[DateTime(2026, 10, 3)], [event]);
  });

  test('doit regrouper les souvenirs d\'un même jour, du plus ancien au plus récent',
      () {
    final evening = buildEvent('soir', DateTime(2026, 10, 3, 21));
    final morning = buildEvent('matin', DateTime(2026, 10, 3, 9));

    final result = useCase([evening, morning]);

    expect(result[DateTime(2026, 10, 3)], [morning, evening]);
  });

  test('doit séparer les souvenirs de jours différents', () {
    final first = buildEvent('1', DateTime(2026, 10, 3));
    final second = buildEvent('2', DateTime(2026, 10, 4));

    final result = useCase([first, second]);

    expect(result, hasLength(2));
    expect(result[DateTime(2026, 10, 3)], [first]);
    expect(result[DateTime(2026, 10, 4)], [second]);
  });
}
