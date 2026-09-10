import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationDataSource {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Get the FCM token for the device
  Future<String?> getToken() => _messaging.getToken();
  // Listen for foreground messages
  Stream<RemoteMessage> onForegroundMessage() => FirebaseMessaging.onMessage;
}