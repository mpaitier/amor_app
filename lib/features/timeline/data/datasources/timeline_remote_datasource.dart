// ============================================================================
// TIMELINE REMOTE DATA SOURCE
// ============================================================================
// Direct Firestore access, isolated from the rest of the app.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/timeline_event_model.dart';

class TimelineRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'timeline_events';

  const TimelineRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // --- Real-time stream of events, ordered by date ---
  Stream<List<TimelineEventModel>> watchEvents() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimelineEventModel.fromFirestore(doc))
            .toList());
  }

  // --- Add a new event document ---
  Future<String> addEvent(TimelineEventModel event) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to add event: $e');
    }
  }

  // --- Update an existing event document ---
  Future<void> updateEvent(TimelineEventModel event) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(event.id)
          .update(event.toFirestore());
    } catch (e) {
      throw ServerException('Failed to update event: $e');
    }
  }

  // --- Delete an event document ---
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
    } catch (e) {
      throw ServerException('Failed to delete event: $e');
    }
  }
}