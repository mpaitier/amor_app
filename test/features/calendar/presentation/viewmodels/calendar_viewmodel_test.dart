// ============================================================================
// TEST UNITAIRE : CalendarViewModel
// ============================================================================
// Le use case WatchTimelineEvents est réel, branché sur un repository factice
// dont on pilote le flux avec un StreamController.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/calendar/domain/entities/calendar_month.dart';
import 'package:amor_app/features/calendar/domain/usecases/group_events_by_day.dart';
import 'package:amor_app/features/calendar/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';
import 'package:amor_app/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/watch_timeline_events.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late MockTimelineRepository mockRepository;
  late StreamController<List<TimelineEventEntity>> eventsController;
  late CalendarViewModel viewModel;

  // --- Laisse le flux livrer ses événements au ViewModel ---
  Future<void> flushStream() => Future<void>.delayed(Duration.zero);

  TimelineEventEntity buildEvent(String id, DateTime date) {
    return TimelineEventEntity(
      id: id,
      title: 'Souvenir $id',
      date: date,
      place: 'Nantes',
      who: 'Titi',
      imageUrl: '',
      description: '',
    );
  }

  setUp(() {
    mockRepository = MockTimelineRepository();
    eventsController = StreamController<List<TimelineEventEntity>>();
    when(() => mockRepository.watchEvents())
        .thenAnswer((_) => eventsController.stream);

    viewModel = CalendarViewModel(
      watchTimelineEvents: WatchTimelineEvents(mockRepository),
      groupEventsByDay: const GroupEventsByDay(),
      now: DateTime(2026, 11, 12, 15, 30),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await eventsController.close();
  });

  group('plage de mois', () {
    test('doit s\'arrêter au mois en cours', () {
      expect(viewModel.lastMonth, const CalendarMonth(2026, 11));
      expect(viewModel.today, DateTime(2026, 11, 12));
    });

    test('doit remonter jusqu\'en janvier, cent ans plus tôt', () {
      expect(viewModel.firstMonth, const CalendarMonth(1926, 1));
      expect(viewModel.monthCount, 100 * 12 + 11);
    });

    test('doit numéroter les mois du plus récent au plus ancien', () {
      expect(viewModel.monthAt(0), const CalendarMonth(2026, 11));
      expect(viewModel.monthAt(1), const CalendarMonth(2026, 10));
      expect(viewModel.monthAt(11), const CalendarMonth(2025, 12));
    });

    test('doit ramener un index hors plage sur la borne la plus proche', () {
      expect(viewModel.monthAt(-5), viewModel.lastMonth);
      expect(viewModel.monthAt(999999), viewModel.firstMonth);
    });

    test('doit retrouver l\'index d\'un mois', () {
      expect(viewModel.indexOf(const CalendarMonth(2026, 11)), 0);
      expect(viewModel.indexOf(const CalendarMonth(2026, 10)), 1);
    });

    test('doit ramener un mois hors plage sur la borne la plus proche', () {
      expect(viewModel.indexOf(const CalendarMonth(2026, 12)), 0);
      expect(
        viewModel.indexOf(const CalendarMonth(1900, 1)),
        viewModel.monthCount - 1,
      );
    });
  });

  group('mois affiché dans l\'en-tête', () {
    test('doit valoir le mois en cours à l\'ouverture', () {
      expect(viewModel.visibleMonth, const CalendarMonth(2026, 11));
    });

    test('doit changer et prévenir quand un autre mois arrive en haut', () {
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.showMonthAt(1);

      expect(viewModel.visibleMonth, const CalendarMonth(2026, 10));
      expect(notifications, 1);
    });

    test('ne doit pas prévenir si le mois en haut reste le même', () {
      viewModel.showMonthAt(1);
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.showMonthAt(1);

      expect(notifications, 0);
    });
  });

  group('souvenirs', () {
    test('ne doit rien renvoyer tant que le flux n\'a rien émis', () {
      expect(viewModel.eventsOn(DateTime(2026, 10, 3)), isEmpty);
    });

    test('doit exposer les souvenirs du jour demandé', () async {
      final event = buildEvent('1', DateTime(2026, 10, 3, 18, 45));
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      eventsController.add([event]);
      await flushStream();

      expect(viewModel.eventsOn(DateTime(2026, 10, 3)), [event]);
      expect(viewModel.eventsOn(DateTime(2026, 10, 4)), isEmpty);
      expect(notifications, 1);
    });

    test('doit accepter un jour donné avec une heure', () async {
      final event = buildEvent('1', DateTime(2026, 10, 3));

      eventsController.add([event]);
      await flushStream();

      expect(viewModel.eventsOn(DateTime(2026, 10, 3, 23, 59)), [event]);
    });

    test('doit remplacer les souvenirs à chaque nouvelle émission', () async {
      eventsController.add([buildEvent('1', DateTime(2026, 10, 3))]);
      await flushStream();

      eventsController.add([buildEvent('2', DateTime(2026, 10, 4))]);
      await flushStream();

      expect(viewModel.eventsOn(DateTime(2026, 10, 3)), isEmpty);
      expect(viewModel.eventsOn(DateTime(2026, 10, 4)), hasLength(1));
    });

    test('doit exposer un message quand le flux échoue', () async {
      eventsController.addError(Exception('Erreur réseau'));
      await flushStream();

      expect(viewModel.errorMessage, contains('Impossible de charger'));
    });
  });

  test('doit s\'abonner au flux dès sa création', () {
    expect(eventsController.hasListener, isTrue);
    verify(() => mockRepository.watchEvents()).called(1);
  });
}
