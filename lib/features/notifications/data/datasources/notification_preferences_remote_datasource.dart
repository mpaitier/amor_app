// ============================================================================
// NOTIFICATION PREFERENCES REMOTE DATA SOURCE
// ============================================================================
// Les préférences sont rangées dans le document de l'appareil, à côté de son
// jeton FCM : device_tokens/{deviceId}.notifications. La Cloud Function les
// lit au moment d'envoyer.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/notification_preferences_model.dart';

class NotificationPreferencesRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'device_tokens';
  static const String _field = 'notifications';

  const NotificationPreferencesRemoteDataSource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Stream<NotificationPreferencesModel> watchPreferences(String deviceId) {
    return _firestore
        .collection(_collection)
        .doc(deviceId)
        .snapshots()
        .map((snapshot) {
      final value = snapshot.data()?[_field];
      return NotificationPreferencesModel.fromMap(
        value is Map<String, dynamic> ? value : null,
      );
    });
  }

  // --- Fusion : le jeton et la date de mise à jour restent intacts ---
  Future<void> savePreferences(
    String deviceId,
    NotificationPreferencesModel preferences,
  ) async {
    try {
      await _firestore.collection(_collection).doc(deviceId).set(
        {_field: preferences.toMap()},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw ServerException('Failed to save notification preferences: $e');
    }
  }
}
