// ============================================================================
// USE CASE: ADD TIMELINE EVENT
// ============================================================================

import '../entities/timeline_event_entity.dart';
import '../repositories/timeline_repository.dart';

class AddTimelineEvent {
  final TimelineRepository _repository;
  const AddTimelineEvent(this._repository);

  Future<String> call(TimelineEventEntity event) {
    return _repository.addEvent(event);
  }
}