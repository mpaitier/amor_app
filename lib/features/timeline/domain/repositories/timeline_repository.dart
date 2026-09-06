// ============================================================================
// TIMELINE REPOSITORY (INTERFACE)
// ============================================================================
// Contract implemented by the data layer. The domain layer only depends
// on this abstraction, never on Firestore directly.

import '../entities/timeline_event_entity.dart';

abstract class TimelineRepository {
  // --- Real-time stream of all timeline events ---
  Stream<List<TimelineEventEntity>> watchEvents();

  // --- Add a new event, returns the created document id ---
  Future<String> addEvent(TimelineEventEntity event);

  // --- Update an existing event ---
  Future<void> updateEvent(TimelineEventEntity event);

  // --- Delete an event ---
  Future<void> deleteEvent(String eventId);
}