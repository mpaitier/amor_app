// <<===========================================================================>>
// <<========================= MODÈLE TIMELINE EVENT ===========================>>
// <<===========================================================================>>

import 'package:cloud_firestore/cloud_firestore.dart';

// <<--- Modèle de données --->
class TimelineEvent {
  // <<--- Champs --->
  final String id;
  final String title;
  final DateTime date;
  final String place;
  final String who;
  final String imageUrl;
  final String description;

  // <<--- Constructeur --->
  const TimelineEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.place,
    required this.who,
    required this.imageUrl,
    required this.description,
  });

  // <<--- Conversion depuis Firestore --->
  factory TimelineEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimelineEvent(
      id          : doc.id,
      title       : data['title'] ?? '',
      date        : (data['date'] as Timestamp).toDate(),
      place       : data['place'] ?? '',
      who         : data['who'] ?? '',
      imageUrl    : data['imageUrl'] ?? '',
      description : data['description'] ?? '',
    );
  }

  // <<--- Conversion vers Firestore --->
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'place': place,
      'who': who,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  // <<--- Copie avec modifications --->
  TimelineEvent copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? place,
    String? who,
    String? imageUrl,
    String? description,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      place: place ?? this.place,
      who: who ?? this.who,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  // <<--- Utilitaire : liste des images depuis imageUrl (séparées par |) --->
  List<String> getImagesList() {
    if (imageUrl.isEmpty) return [];

    return imageUrl.split('|').map((url) {
      final trimmed = url.trim();

      // <<--- Correction des liens Imgur sans extension --->
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