// ============================================================================
// NOTIFICATION PREFERENCES REPOSITORY (INTERFACE)
// ============================================================================
// Préférences de notifications de CE téléphone.

import '../entities/notification_preferences.dart';

abstract class NotificationPreferencesRepository {
  // --- Flux temps réel. Émet les valeurs d'origine tant que rien n'a été
  // --- enregistré ---
  Stream<NotificationPreferences> watchPreferences();

  Future<void> savePreferences(NotificationPreferences preferences);
}
