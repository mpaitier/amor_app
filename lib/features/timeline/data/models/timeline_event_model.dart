// ============================================================================
// TIMELINE EVENT MODEL
// ============================================================================
// Data Transfer Object mapping Firestore documents to/from the domain entity.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/timeline_event_entity.dart';

class TimelineEventModel extends TimelineEventEntity {
  const TimelineEventModel({
    required super.id,
    required super.title,
    required super.date,
    required super.place,
    required super.imageUrl,
    required super.description,
    super.creatorUid,
    super.creatorDeviceId,
    super.gifUrl,
  });

  // --- Build from a Firestore document snapshot ---
  factory TimelineEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimelineEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      place: data['place'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      creatorUid: data['creatorUid'] ?? '',
      creatorDeviceId: data['creatorDeviceId'] ?? '',
      gifUrl: data['gifUrl'] ?? '',
    );
  }

  // --- Build from a domain entity (used before writing to Firestore) ---
  factory TimelineEventModel.fromEntity(TimelineEventEntity entity) {
    return TimelineEventModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      place: entity.place,
      imageUrl: entity.imageUrl,
      description: entity.description,
      creatorUid: entity.creatorUid,
      creatorDeviceId: entity.creatorDeviceId,
      gifUrl: entity.gifUrl,
    );
  }

  // --- Convert to a Firestore-compatible map ---
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'place': place,
      'imageUrl': imageUrl,
      'description': description,
      'creatorUid': creatorUid,
      'creatorDeviceId': creatorDeviceId,
      'gifUrl': gifUrl,
    };
  }
}