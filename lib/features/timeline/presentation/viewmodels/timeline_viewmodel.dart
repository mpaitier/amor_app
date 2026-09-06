// ============================================================================
// TIMELINE VIEWMODEL
// ============================================================================
// Holds the list of events (real-time) and exposes sorting / deletion
// actions to the presentation layer.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/timeline_event_entity.dart';
import '../../domain/usecases/watch_timeline_events.dart';
import '../../domain/usecases/delete_timeline_event.dart';

class TimelineViewModel extends ChangeNotifier {
  final WatchTimelineEvents _watchTimelineEvents;
  final DeleteTimelineEvent _deleteTimelineEvent;

  StreamSubscription<List<TimelineEventEntity>>? _subscription;

  // --- State ---
  List<TimelineEventEntity> _events = [];
  bool _isLoading = true;
  bool _isDescending = true;
  String? _errorMessage;

  TimelineViewModel({
    required WatchTimelineEvents watchTimelineEvents,
    required DeleteTimelineEvent deleteTimelineEvent,
  })  : _watchTimelineEvents = watchTimelineEvents,
        _deleteTimelineEvent = deleteTimelineEvent {
    _listenToEvents();
  }

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isDescending => _isDescending;
  String? get errorMessage => _errorMessage;

  List<TimelineEventEntity> get sortedEvents {
    final sorted = [..._events];
    sorted.sort((a, b) =>
        _isDescending ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return sorted;
  }

  TimelineEventEntity? eventById(String id) {
    for (final event in _events) {
      if (event.id == id) return event;
    }
    return null;
  }

  // --- Subscribe to the real-time event stream ---
  void _listenToEvents() {
    _subscription = _watchTimelineEvents().listen((events) {
      _events = events;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Unable to load your memories: $error';
      _isLoading = false;
      notifyListeners();
    });
  }

  // --- Toggle the sort order (ascending / descending) ---
  void toggleSortOrder() {
    _isDescending = !_isDescending;
    notifyListeners();
  }

  // --- Delete an event, returns true on success ---
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _deleteTimelineEvent(eventId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete this memory: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}