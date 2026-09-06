// ============================================================================
// USE CASE: WATCH TIMELINE EVENTS
// ============================================================================

import '../entities/timeline_event_entity.dart';
import '../repositories/timeline_repository.dart';

class WatchTimelineEvents {
  final TimelineRepository _repository;
  const WatchTimelineEvents(this._repository);

  Stream<List<TimelineEventEntity>> call() {
    return _repository.watchEvents();
  }
}