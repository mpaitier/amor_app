// ============================================================================
// IMPORTANT DATE REMOTE DATA SOURCE
// ============================================================================
// Accès direct à Firestore, isolé du reste de l'app.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/important_date_model.dart';

class ImportantDateRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'important_dates';

  const ImportantDateRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // --- Flux temps réel des dates, triées par jour ---
  Stream<List<ImportantDateModel>> watchImportantDates() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ImportantDateModel.fromFirestore(doc))
            .toList());
  }

  // --- Ajoute un document ---
  Future<String> addImportantDate(ImportantDateModel date) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(date.toFirestore());
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to add important date: $e');
    }
  }

  // --- Met à jour un document existant ---
  Future<void> updateImportantDate(ImportantDateModel date) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(date.id)
          .update(date.toFirestore());
    } catch (e) {
      throw ServerException('Failed to update important date: $e');
    }
  }

  // --- Supprime un document ---
  Future<void> deleteImportantDate(String dateId) async {
    try {
      await _firestore.collection(_collection).doc(dateId).delete();
    } catch (e) {
      throw ServerException('Failed to delete important date: $e');
    }
  }
}
