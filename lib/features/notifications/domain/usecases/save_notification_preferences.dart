// ============================================================================
// USE CASE: SAVE NOTIFICATION PREFERENCES
// ============================================================================

import '../entities/notification_preferences.dart';
import '../repositories/notification_preferences_repository.dart';

class SaveNotificationPreferences {
  final NotificationPreferencesRepository _repository;
  const SaveNotificationPreferences(this._repository);

  Future<void> call(NotificationPreferences preferences) {
    return _repository.savePreferences(preferences);
  }
}
