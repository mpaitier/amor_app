// ============================================================================
// TEST UNITAIRE : NotificationPreferencesViewModel
// ============================================================================

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/notifications/domain/entities/notification_preferences.dart';
import 'package:amor_app/features/notifications/domain/repositories/notification_preferences_repository.dart';
import 'package:amor_app/features/notifications/domain/usecases/save_notification_preferences.dart';
import 'package:amor_app/features/notifications/domain/usecases/watch_notification_preferences.dart';
import 'package:amor_app/features/notifications/presentation/viewmodels/notification_preferences_viewmodel.dart';

class MockNotificationPreferencesRepository extends Mock
    implements NotificationPreferencesRepository {}

class _FakeNotificationPreferences extends Fake
    implements NotificationPreferences {}

void main() {
  late MockNotificationPreferencesRepository mockRepository;
  late StreamController<NotificationPreferences> controller;
  late NotificationPreferencesViewModel viewModel;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUpAll(() {
    registerFallbackValue(_FakeNotificationPreferences());
  });

  setUp(() {
    mockRepository = MockNotificationPreferencesRepository();
    controller = StreamController<NotificationPreferences>();
    when(() => mockRepository.watchPreferences())
        .thenAnswer((_) => controller.stream);
    when(() => mockRepository.savePreferences(any())).thenAnswer((_) async {});

    viewModel = NotificationPreferencesViewModel(
      watchPreferences: WatchNotificationPreferences(mockRepository),
      savePreferences: SaveNotificationPreferences(mockRepository),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await controller.close();
  });

  NotificationPreferences lastSaved() {
    return verify(() => mockRepository.savePreferences(captureAny()))
        .captured
        .last as NotificationPreferences;
  }

  test('doit charger tant que le flux n\'a rien émis', () {
    expect(viewModel.isLoading, isTrue);
  });

  test('doit exposer les préférences reçues', () async {
    controller.add(const NotificationPreferences(newMemory: false));
    await flush();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.preferences.newMemory, isFalse);
  });

  test('doit enregistrer aussitôt l\'interrupteur général', () async {
    controller.add(const NotificationPreferences());
    await flush();

    await viewModel.setEnabled(false);

    expect(viewModel.preferences.enabled, isFalse);
    expect(lastSaved().enabled, isFalse);
  });

  test('doit enregistrer l\'heure du jour J et celle du rappel', () async {
    controller.add(const NotificationPreferences());
    await flush();

    await viewModel.setDayOfTime(8 * 60);
    await viewModel.setReminderTime(21 * 60 + 30);

    expect(lastSaved().dayOfTime, 480);
    expect(lastSaved().reminderTime, 1290);
  });

  test('doit borner le nombre de jours du rappel', () async {
    controller.add(const NotificationPreferences());
    await flush();

    await viewModel.setReminderDaysBefore(0);
    expect(lastSaved().reminderDaysBefore, 1);

    await viewModel.setReminderDaysBefore(500);
    expect(
      lastSaved().reminderDaysBefore,
      NotificationPreferencesViewModel.maxReminderDays,
    );
  });

  test('doit exposer un message si l\'enregistrement échoue', () async {
    when(() => mockRepository.savePreferences(any()))
        .thenThrow(Exception('Firestore indisponible'));
    controller.add(const NotificationPreferences());
    await flush();

    await viewModel.setNewMemory(false);

    expect(viewModel.errorMessage, contains('Enregistrement impossible'));
  });
}
