// ============================================================================
// USE CASE: WATCH NOTIFICATION PREFERENCES
// ============================================================================

import '../entities/notification_preferences.dart';
import '../repositories/notification_preferences_repository.dart';

class WatchNotificationPreferences {
  final NotificationPreferencesRepository _repository;
  const WatchNotificationPreferences(this._repository);

  Stream<NotificationPreferences> call() => _repository.watchPreferences();
}
