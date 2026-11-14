// ============================================================================
// TIMELINE EVENT ENTITY
// ============================================================================
// Pure domain model, independent from Firestore or any other data source.

class TimelineEventEntity {
  final String id;
  final String title;
  final DateTime date;
  final String place;
  final String imageUrl;
  final String description;

  // --- uid de la personne qui a créé le souvenir. Son surnom et sa couleur
  // --- viennent de son profil dans la relation ---
  final String creatorUid;

  // --- Téléphone d'origine : la notification ne lui est pas renvoyée ---
  final String creatorDeviceId;

  // --- GIF tiré au hasard à la création, vide pour les anciens souvenirs ---
  final String gifUrl;

  const TimelineEventEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.place,
    required this.imageUrl,
    required this.description,
    this.creatorUid = '',
    this.creatorDeviceId = '',
    this.gifUrl = '',
  });

  // --- Copy with modifications ---
  TimelineEventEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? place,
    String? imageUrl,
    String? description,
    String? creatorUid,
    String? creatorDeviceId,
    String? gifUrl,
  }) {
    return TimelineEventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      place: place ?? this.place,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      creatorUid: creatorUid ?? this.creatorUid,
      creatorDeviceId: creatorDeviceId ?? this.creatorDeviceId,
      gifUrl: gifUrl ?? this.gifUrl,
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