// ============================================================================
// TEST UNITAIRE : NotificationPreferences
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/notifications/domain/entities/notification_preferences.dart';

void main() {
  test('doit notifier les jours spéciaux par défaut', () {
    expect(const NotificationPreferences().notifiesSpecialDays, isTrue);
  });

  test('ne doit plus notifier les jours spéciaux une fois tout coupé', () {
    const preferences = NotificationPreferences(enabled: false);

    expect(preferences.notifiesSpecialDays, isFalse);
  });

  test('ne doit plus notifier sans dates ni anniversaires', () {
    const preferences = NotificationPreferences(
      importantDates: false,
      anniversaries: false,
    );

    expect(preferences.notifiesSpecialDays, isFalse);
  });

  test('copyWith doit ne remplacer que les champs fournis', () {
    final copy = const NotificationPreferences().copyWith(reminderDaysBefore: 7);

    expect(copy.reminderDaysBefore, 7);
    expect(copy.enabled, isTrue);
    expect(copy.dayOfTime, NotificationPreferences.defaultDayOfTime);
  });
}
