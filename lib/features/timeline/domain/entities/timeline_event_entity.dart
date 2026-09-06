// ============================================================================
// TIMELINE EVENT ENTITY
// ============================================================================
// Pure domain model, independent from Firestore or any other data source.

class TimelineEventEntity {
  final String id;
  final String title;
  final DateTime date;
  final String place;
  final String who;
  final String imageUrl;
  final String description;

  const TimelineEventEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.place,
    required this.who,
    required this.imageUrl,
    required this.description,
  });

  // --- Copy with modifications ---
  TimelineEventEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? place,
    String? who,
    String? imageUrl,
    String? description,
  }) {
    return TimelineEventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      place: place ?? this.place,
      who: who ?? this.who,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  // --- List of image urls, split on the '|' separator ---
  List<String> get imagesList {
    if (imageUrl.isEmpty) return [];

    return imageUrl.split('|').map((url) {
      final trimmed = url.trim();

      // --- Fix Imgur links missing a file extension ---
      if (trimmed.contains('imgur.com') &&
          !trimmed.endsWith('.png') &&
          !trimmed.endsWith('.jpg') &&
          !trimmed.endsWith('.jpeg') &&
          !trimmed.endsWith('.gif')) {
        return '$trimmed.png';
      }
      return trimmed;
    }).toList();
  }
}