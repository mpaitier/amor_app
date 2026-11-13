// ============================================================================
// TEST UNITAIRE : CalendarViewModel
// ============================================================================
// Les use cases sont réels, branchés sur des repositories factices dont on
// pilote les flux avec des StreamController.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/calendar/domain/entities/calendar_month.dart';
import 'package:amor_app/features/calendar/domain/entities/calendar_special_day.dart';
import 'package:amor_app/features/calendar/domain/usecases/build_special_days.dart';
import 'package:amor_app/features/calendar/domain/usecases/group_events_by_day.dart';
import 'package:amor_app/features/calendar/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';
import 'package:amor_app/features/important_dates/domain/repositories/important_date_repository.dart';
import 'package:amor_app/features/important_dates/domain/usecases/delete_important_date.dart';
import 'package:amor_app/features/important_dates/domain/usecases/watch_important_dates.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';
import 'package:amor_app/features/settings/domain/repositories/couple_settings_repository.dart';
import 'package:amor_app/features/settings/domain/usecases/watch_couple_settings.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';
import 'package:amor_app/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:amor_app/features/timeline/domain/usecases/watch_timeline_events.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

class MockImportantDateRepository extends Mock
    implements ImportantDateRepository {}

class MockCoupleSettingsRepository extends Mock
    implements CoupleSettingsRepository {}

void main() {
  late MockTimelineRepository mockTimelineRepository;
  late MockImportantDateRepository mockDateRepository;
  late MockCoupleSettingsRepository mockSettingsRepository;
  late StreamController<List<TimelineEventEntity>> eventsController;
  late StreamController<List<ImportantDateEntity>> datesController;
  late StreamController<CoupleSettingsEntity> settingsController;
  late CalendarViewModel viewModel;

  // --- Laisse les flux livrer leurs événements au ViewModel ---
  Future<void> flushStreams() => Future<void>.delayed(Duration.zero);

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

  ImportantDateEntity buildDate(
    String id,
    DateTime date, {
    ImportantDateRecurrence recurrence = ImportantDateRecurrence.none,
  }) {
    return ImportantDateEntity(
      id: id,
      title: 'Date $id',
      date: date,
      emoji: '🎂',
      recurrence: recurrence,
    );
  }

  // --- Les dates importantes d'un jour, sans les anniversaires ---
  List<ImportantDateEntity> importantDatesOn(DateTime day) {
    return [
      for (final specialDay in viewModel.specialDaysOn(day))
        if (specialDay.importantDate != null) specialDay.importantDate!,
    ];
  }

  // --- Début de l'histoire : le 12 décembre 2023 ---
  final tSettings = CoupleSettingsEntity(
    relationshipStart: DateTime(2023, 12, 12),
  );

  setUp(() {
    mockTimelineRepository = MockTimelineRepository();
    mockDateRepository = MockImportantDateRepository();
    mockSettingsRepository = MockCoupleSettingsRepository();
    eventsController = StreamController<List<TimelineEventEntity>>();
    datesController = StreamController<List<ImportantDateEntity>>();
    settingsController = StreamController<CoupleSettingsEntity>();
    when(() => mockTimelineRepository.watchEvents())
        .thenAnswer((_) => eventsController.stream);
    when(() => mockDateRepository.watchImportantDates())
        .thenAnswer((_) => datesController.stream);
    when(() => mockSettingsRepository.watchSettings())
        .thenAnswer((_) => settingsController.stream);

    viewModel = CalendarViewModel(
      watchTimelineEvents: WatchTimelineEvents(mockTimelineRepository),
      watchImportantDates: WatchImportantDates(mockDateRepository),
      deleteImportantDate: DeleteImportantDate(mockDateRepository),
      watchCoupleSettings: WatchCoupleSettings(mockSettingsRepository),
      groupEventsByDay: const GroupEventsByDay(),
      buildSpecialDays: const BuildSpecialDays(),
      now: DateTime(2026, 11, 12, 15, 30),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await eventsController.close();
    await datesController.close();
    await settingsController.close();
  });

  group('plage de mois sans date à venir', () {
    test('doit s\'arrêter au mois en cours', () {
      expect(viewModel.lastMonth, const CalendarMonth(2026, 11));
      expect(viewModel.currentMonth, const CalendarMonth(2026, 11));
      expect(viewModel.currentMonthIndex, 0);
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

  group('plage de mois avec dates importantes', () {
    test('doit s\'étendre jusqu\'au mois d\'une date à venir', () async {
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      datesController.add([buildDate('1', DateTime(2026, 12, 28))]);
      await flushStreams();

      expect(viewModel.lastMonth, const CalendarMonth(2026, 12));
      expect(viewModel.monthCount, 100 * 12 + 12);
      expect(viewModel.currentMonthIndex, 1);
      expect(viewModel.monthAt(0), const CalendarMonth(2026, 12));
      expect(viewModel.indexOf(const CalendarMonth(2026, 11)), 1);
      expect(notifications, 1);
    });

    test('doit retenir la date à venir la plus lointaine', () async {
      datesController.add([
        buildDate('1', DateTime(2026, 12, 28)),
        buildDate('2', DateTime(2027, 6, 1)),
        buildDate('3', DateTime(2027, 2, 14)),
      ]);
      await flushStreams();

      expect(viewModel.lastMonth, const CalendarMonth(2027, 6));
    });

    test('ne doit pas s\'étendre pour une date ponctuelle passée', () async {
      datesController.add([buildDate('1', DateTime(2025, 6, 1))]);
      await flushStreams();

      expect(viewModel.lastMonth, const CalendarMonth(2026, 11));
    });

    test('doit s\'étendre jusqu\'à la prochaine occurrence d\'une date répétée',
        () async {
      datesController.add([
        buildDate('1', DateTime(2023, 12, 12), recurrence: ImportantDateRecurrence.yearly),
      ]);
      await flushStreams();

      expect(viewModel.lastMonth, const CalendarMonth(2026, 12));
    });

    test('doit viser l\'année suivante si l\'occurrence de l\'année est passée',
        () async {
      datesController.add([
        buildDate('1', DateTime(2024, 3, 3), recurrence: ImportantDateRecurrence.yearly),
      ]);
      await flushStreams();

      expect(viewModel.lastMonth, const CalendarMonth(2027, 3));
    });

    test('doit s\'étendre jusqu\'à la prochaine occurrence hebdomadaire',
        () async {
      // --- Tous les mardis depuis le 3 novembre. Le jour simulé est le
      // --- jeudi 12 : le prochain mardi est le 17, encore en novembre ---
      datesController.add([
        buildDate(
          '1',
          DateTime(2026, 11, 3),
          recurrence: ImportantDateRecurrence.weekly,
        ),
      ]);
      await flushStreams();

      expect(viewModel.lastMonth, const CalendarMonth(2026, 11));
      expect(importantDatesOn(DateTime(2026, 11, 17)), hasLength(1));
    });

    test('doit revenir au mois en cours quand la date disparaît', () async {
      datesController.add([buildDate('1', DateTime(2026, 12, 28))]);
      await flushStreams();

      datesController.add([]);
      await flushStreams();

      expect(viewModel.lastMonth, const CalendarMonth(2026, 11));
      expect(viewModel.currentMonthIndex, 0);
    });
  });

  group('mois affiché dans l\'en-tête', () {
    test('doit valoir le mois en cours à l\'ouverture', () {
      expect(viewModel.visibleMonth, const CalendarMonth(2026, 11));
    });

    test('doit changer et prévenir quand un autre mois arrive en haut', () {
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.showMonth(const CalendarMonth(2026, 10));

      expect(viewModel.visibleMonth, const CalendarMonth(2026, 10));
      expect(notifications, 1);
    });

    test('ne doit pas prévenir si le mois en haut reste le même', () {
      viewModel.showMonth(const CalendarMonth(2026, 10));
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.showMonth(const CalendarMonth(2026, 10));

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
      await flushStreams();

      expect(viewModel.eventsOn(DateTime(2026, 10, 3)), [event]);
      expect(viewModel.eventsOn(DateTime(2026, 10, 4)), isEmpty);
      expect(notifications, 1);
    });

    test('doit accepter un jour donné avec une heure', () async {
      final event = buildEvent('1', DateTime(2026, 10, 3));

      eventsController.add([event]);
      await flushStreams();

      expect(viewModel.eventsOn(DateTime(2026, 10, 3, 23, 59)), [event]);
    });

    test('doit remplacer les souvenirs à chaque nouvelle émission', () async {
      eventsController.add([buildEvent('1', DateTime(2026, 10, 3))]);
      await flushStreams();

      eventsController.add([buildEvent('2', DateTime(2026, 10, 4))]);
      await flushStreams();

      expect(viewModel.eventsOn(DateTime(2026, 10, 3)), isEmpty);
      expect(viewModel.eventsOn(DateTime(2026, 10, 4)), hasLength(1));
    });

    test('doit exposer un message quand le flux échoue', () async {
      eventsController.addError(Exception('Erreur réseau'));
      await flushStreams();

      expect(viewModel.errorMessage, contains('Impossible de charger'));
    });
  });

  group('dates importantes', () {
    test('ne doit rien renvoyer tant que le flux n\'a rien émis', () {
      expect(importantDatesOn(DateTime(2026, 12, 28)), isEmpty);
    });

    test('doit exposer une date ponctuelle le jour prévu seulement', () async {
      final date = buildDate('1', DateTime(2026, 12, 28));

      datesController.add([date]);
      await flushStreams();

      expect(importantDatesOn(DateTime(2026, 12, 28)), [date]);
      expect(importantDatesOn(DateTime(2026, 12, 27)), isEmpty);
      expect(importantDatesOn(DateTime(2027, 12, 28)), isEmpty);
    });

    test('doit exposer une date répétée chaque année depuis la première',
        () async {
      final date = buildDate('1', DateTime(2023, 12, 12), recurrence: ImportantDateRecurrence.yearly);

      datesController.add([date]);
      await flushStreams();

      expect(importantDatesOn(DateTime(2023, 12, 12)), [date]);
      expect(importantDatesOn(DateTime(2025, 12, 12)), [date]);
      expect(importantDatesOn(DateTime(2022, 12, 12)), isEmpty);
    });

    test('doit exposer un message quand le flux échoue', () async {
      datesController.addError(Exception('Erreur réseau'));
      await flushStreams();

      expect(viewModel.errorMessage, contains('dates importantes'));
    });
  });

  group('deleteImportantDate', () {
    test('doit supprimer la date et renvoyer true', () async {
      when(() => mockDateRepository.deleteImportantDate('date_1'))
          .thenAnswer((_) async {});

      final deleted = await viewModel.deleteImportantDate('date_1');

      expect(deleted, isTrue);
      verify(() => mockDateRepository.deleteImportantDate('date_1')).called(1);
    });

    test('doit exposer un message et renvoyer false si la suppression échoue',
        () async {
      when(() => mockDateRepository.deleteImportantDate('date_1'))
          .thenThrow(Exception('Firestore indisponible'));

      final deleted = await viewModel.deleteImportantDate('date_1');

      expect(deleted, isFalse);
      expect(viewModel.errorMessage, contains('Impossible de supprimer'));
    });
  });

  group('anniversaires', () {
    test('ne doit rien afficher tant que les réglages ne sont pas activés',
        () async {
      settingsController.add(tSettings);
      await flushStreams();

      expect(viewModel.specialDaysOn(DateTime(2025, 12, 12)), isEmpty);
      expect(viewModel.lastMonth, const CalendarMonth(2026, 11));
    });

    test('doit afficher l\'anniversaire et s\'étendre jusqu\'au prochain',
        () async {
      settingsController.add(tSettings.copyWith(showAnniversary: true));
      await flushStreams();

      final specialDays = viewModel.specialDaysOn(DateTime(2026, 12, 12));
      expect(specialDays, hasLength(1));
      expect(specialDays.first.kind, CalendarSpecialDayKind.anniversary);
      expect(specialDays.first.title, '3e anniversaire');
      expect(viewModel.lastMonth, const CalendarMonth(2026, 12));
    });

    test('doit afficher les mois-anniversaires', () async {
      settingsController.add(
        tSettings.copyWith(showMonthAnniversaries: true),
      );
      await flushStreams();

      final specialDays = viewModel.specialDaysOn(DateTime(2026, 11, 12));
      expect(specialDays, hasLength(1));
      expect(specialDays.first.title, '35 mois');
      expect(viewModel.lastMonth, const CalendarMonth(2026, 11));
    });

    test('doit placer l\'anniversaire avant les dates importantes du jour',
        () async {
      settingsController.add(tSettings.copyWith(showAnniversary: true));
      datesController.add([buildDate('1', DateTime(2026, 12, 12))]);
      await flushStreams();

      final specialDays = viewModel.specialDaysOn(DateTime(2026, 12, 12));
      expect(specialDays.map((day) => day.kind), [
        CalendarSpecialDayKind.anniversary,
        CalendarSpecialDayKind.importantDate,
      ]);
    });
  });

  test('doit s\'abonner aux trois flux dès sa création', () {
    expect(eventsController.hasListener, isTrue);
    expect(datesController.hasListener, isTrue);
    expect(settingsController.hasListener, isTrue);
    verify(() => mockTimelineRepository.watchEvents()).called(1);
    verify(() => mockDateRepository.watchImportantDates()).called(1);
    verify(() => mockSettingsRepository.watchSettings()).called(1);
  });
}
