// ============================================================================
// USE CASE: UPDATE TIMELINE EVENT
// ============================================================================

import '../entities/timeline_event_entity.dart';
import '../repositories/timeline_repository.dart';

class UpdateTimelineEvent {
  final TimelineRepository _repository;
  const UpdateTimelineEvent(this._repository);

  Future<void> call(TimelineEventEntity event) {
    return _repository.updateEvent(event);
  }
}