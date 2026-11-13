// ============================================================================
// TEST UNITAIRE : NotificationPreferencesModel
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/notifications/data/models/notification_preferences_model.dart';
import 'package:amor_app/features/notifications/domain/entities/notification_preferences.dart';

void main() {
  group('formatTime / parseTime', () {
    test('doit écrire les heures sur deux chiffres', () {
      expect(NotificationPreferencesModel.formatTime(9 * 60), '09:00');
      expect(NotificationPreferencesModel.formatTime(18 * 60 + 5), '18:05');
    });

    test('doit relire une heure écrite', () {
      expect(NotificationPreferencesModel.parseTime('09:30'), 570);
    });

    test('doit refuser une heure illisible', () {
      expect(NotificationPreferencesModel.parseTime('25:00'), isNull);
      expect(NotificationPreferencesModel.parseTime('9h'), isNull);
      expect(NotificationPreferencesModel.parseTime(42), isNull);
    });
  });

  group('fromMap', () {
    test('doit donner les valeurs d\'origine sans réglage', () {
      final model = NotificationPreferencesModel.fromMap(null);

      expect(model.enabled, isTrue);
      expect(model.newMemory, isTrue);
      expect(model.importantDates, isTrue);
      expect(model.anniversaries, isTrue);
      expect(model.dayOfTime, NotificationPreferences.defaultDayOfTime);
      expect(model.reminderEnabled, isFalse);
      expect(model.reminderDaysBefore, 1);
      expect(model.reminderTime, NotificationPreferences.defaultReminderTime);
    });

    test('doit relire ce que toMap a écrit', () {
      const preferences = NotificationPreferences(
        enabled: true,
        newMemory: false,
        importantDates: true,
        anniversaries: false,
        dayOfTime: 8 * 60 + 15,
        reminderEnabled: true,
        reminderDaysBefore: 3,
        reminderTime: 20 * 60,
      );

      final map = NotificationPreferencesModel.fromEntity(preferences).toMap();
      final model = NotificationPreferencesModel.fromMap(map);

      expect(map['dayOfTime'], '08:15');
      expect(map['reminderTime'], '20:00');
      expect(model.newMemory, isFalse);
      expect(model.anniversaries, isFalse);
      expect(model.dayOfTime, 495);
      expect(model.reminderEnabled, isTrue);
      expect(model.reminderDaysBefore, 3);
      expect(model.reminderTime, 1200);
    });
  });
}
