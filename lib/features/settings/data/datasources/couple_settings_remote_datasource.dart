// ============================================================================
// COUPLE SETTINGS REMOTE DATA SOURCE
// ============================================================================
// Les réglages tiennent dans un seul document Firestore, partagé par les
// deux téléphones : app_settings/couple.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/couple_settings_model.dart';

class CoupleSettingsRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'app_settings';
  static const String _document = 'couple';

  const CoupleSettingsRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  DocumentReference<Map<String, dynamic>> get _reference =>
      _firestore.collection(_collection).doc(_document);

  // --- Flux temps réel du document ---
  Stream<CoupleSettingsModel> watchSettings() {
    return _reference
        .snapshots()
        .map((snapshot) => CoupleSettingsModel.fromFirestore(snapshot));
  }

  // --- Écrit le document, en le créant au besoin ---
  Future<void> saveSettings(CoupleSettingsModel settings) async {
    try {
      await _reference.set(settings.toFirestore());
    } catch (e) {
      throw ServerException('Failed to save settings: $e');
    }
  }
}
