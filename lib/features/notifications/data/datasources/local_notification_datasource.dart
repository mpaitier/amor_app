import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationDataSource {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'amor_memories',
    'Nouveaux souvenirs',
    channelDescription: 'Notifications pour les nouveaux souvenirs ajoutés',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);
  }

  Future<void> show({required String title, required String body}) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: _androidDetails),
    );
  }
} 