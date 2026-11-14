// ============================================================================
// COUPLE SETTINGS REMOTE DATA SOURCE
// ============================================================================
// Les réglages tiennent dans un seul document Firestore, partagé par les
// membres de la relation : couples/{coupleId}/settings/general.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/session/current_couple.dart';
import '../models/couple_settings_model.dart';

class CoupleSettingsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CurrentCouple _currentCouple;
  static const String _collection = 'settings';
  static const String _document = 'general';

  const CoupleSettingsRemoteDataSource({
    required FirebaseFirestore firestore,
    required CurrentCouple currentCouple,
  })  : _firestore = firestore,
        _currentCouple = currentCouple;

  // --- Document de la relation active, résolu à chaque appel ---
  DocumentReference<Map<String, dynamic>> get _reference =>
      _firestore.collection(_currentCouple.path(_collection)).doc(_document);

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
