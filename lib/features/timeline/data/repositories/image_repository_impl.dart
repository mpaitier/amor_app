// ============================================================================
// TIMELINE REPOSITORY (IMPLEMENTATION)
// ============================================================================
// Implements the domain contract on top of the Firestore data source.

import '../../domain/entities/timeline_event_entity.dart';
import '../../domain/repositories/timeline_repository.dart';
import '../datasources/timeline_remote_datasource.dart';
import '../models/timeline_event_model.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  final TimelineRemoteDataSource _remoteDataSource;

  const TimelineRepositoryImpl({
    required TimelineRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<List<TimelineEventEntity>> watchEvents() {
    return _remoteDataSource.watchEvents();
  }

  @override
  Future<String> addEvent(TimelineEventEntity event) {
    return _remoteDataSource.addEvent(TimelineEventModel.fromEntity(event));
  }

  @override
  Future<void> updateEvent(TimelineEventEntity event) {
    return _remoteDataSource.updateEvent(TimelineEventModel.fromEntity(event));
  }

  @override
  Future<void> deleteEvent(String eventId) {
    return _remoteDataSource.deleteEvent(eventId);
  }
}