import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/device_identity_datasource.dart';
import '../datasources/push_notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final PushNotificationDataSource _pushDataSource;
  final DeviceIdentityDataSource _deviceIdentityDataSource;
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({
    required PushNotificationDataSource pushDataSource,
    required DeviceIdentityDataSource deviceIdentityDataSource,
    required FirebaseFirestore firestore,
  })  : _pushDataSource = pushDataSource,
        _deviceIdentityDataSource = deviceIdentityDataSource,
        _firestore = firestore;
  
  @override
  Future<void> initialize() async {
    final granted = await _pushDataSource.requestPermission();
    if (!granted) return;
    await registerDeviceToken();
  }

  @override
  Future<void> registerDeviceToken() async {
    final token = await _pushDataSource.getToken();
    if (token == null) return;

    final deviceId = await _deviceIdentityDataSource.getOrCreateDeviceId();

    await _firestore.collection('device_tokens').doc(deviceId).set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> getDeviceId() => _deviceIdentityDataSource.getOrCreateDeviceId();
}