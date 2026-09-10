abstract class NotificationRepository {
  Future<void> initialize();
  Future<void> registerDeviceToken();
  Future<String> getDeviceId();
}