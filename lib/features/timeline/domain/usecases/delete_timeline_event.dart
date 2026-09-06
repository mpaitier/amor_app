// ============================================================================
// USE CASE: DELETE TIMELINE EVENT
// ============================================================================

import '../repositories/timeline_repository.dart';

class DeleteTimelineEvent {
  final TimelineRepository _repository;
  const DeleteTimelineEvent(this._repository);

  Future<void> call(String eventId) {
    return _repository.deleteEvent(eventId);
  }
}