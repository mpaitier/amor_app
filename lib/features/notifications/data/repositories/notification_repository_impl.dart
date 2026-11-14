// ============================================================================
// NOTIFICATION REPOSITORY (IMPLEMENTATION)
// ============================================================================
// Permission, jeton FCM et affichage des notifications reçues app ouverte.
// Le document device_tokens/{deviceId} porte l'uid du compte connecté : les
// Cloud Functions n'envoient ainsi qu'aux membres de la relation concernée.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/device_identity_datasource.dart';
import '../datasources/local_notification_datasource.dart';
import '../datasources/push_notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final PushNotificationDataSource _pushDataSource;
  final LocalNotificationDataSource _localDataSource;
  final DeviceIdentityDataSource _deviceIdentityDataSource;
  final FirebaseFirestore _firestore;

  // --- uid du compte connecté, null avant la connexion ---
  final String? Function() _currentUid;

  NotificationRepositoryImpl({
    required PushNotificationDataSource pushDataSource,
    required LocalNotificationDataSource localDataSource,
    required DeviceIdentityDataSource deviceIdentityDataSource,
    required FirebaseFirestore firestore,
    required String? Function() currentUid,
  })  : _pushDataSource = pushDataSource,
        _localDataSource = localDataSource,
        _deviceIdentityDataSource = deviceIdentityDataSource,
        _firestore = firestore,
        _currentUid = currentUid;

  @override
  Future<void> initialize() async {
    await _localDataSource.initialize();

    final granted = await _pushDataSource.requestPermission();
    if (!granted) return;

    await registerDeviceToken();

    // --- Affichage manuel quand l'app est ouverte (FCM ne le fait pas seul) ---
    _pushDataSource.onForegroundMessage().listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localDataSource.show(
        title: notification.title ?? 'Amor',
        body: notification.body ?? '',
      );
    });
  }

  @override
  Future<void> registerDeviceToken() async {
    try {
      final token = await _pushDataSource.getToken();
      if (token == null) return;

      final deviceId = await _deviceIdentityDataSource.getOrCreateDeviceId();
      final uid = _currentUid();

      // --- Fusion : les préférences de notifications rangées dans le même
      // --- document ne sont pas effacées à chaque lancement. L'uid n'est
      // --- écrit que s'il est connu : un lancement avant la restauration
      // --- de la session ne l'efface pas ---
      await _firestore.collection('device_tokens').doc(deviceId).set(
        {
          'token': token,
          'updatedAt': FieldValue.serverTimestamp(),
          if (uid != null) 'uid': uid,
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // --- Pas de réseau ou jeton indisponible : nouvel essai au prochain
      // --- lancement ou à la prochaine connexion ---
    }
  }

  @override
  Future<String> getDeviceId() => _deviceIdentityDataSource.getOrCreateDeviceId();
}