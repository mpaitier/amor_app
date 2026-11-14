abstract class NotificationRepository {
  Future<void> initialize();

  // --- Jeton FCM du téléphone, rattaché au compte connecté ---
  Future<void> registerDeviceToken();

  // --- Retire le compte du document du téléphone : il ne reçoit plus les
  // --- notifications de la relation. À appeler avant la déconnexion ---
  Future<void> unregisterDeviceToken();

  Future<String> getDeviceId();
}