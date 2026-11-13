// ============================================================================
// IMPORTANT DATE MODEL
// ============================================================================
// Data Transfer Object : convertit un document Firestore en entité de
// domaine, et inversement.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/important_date_entity.dart';

class ImportantDateModel extends ImportantDateEntity {
  const ImportantDateModel({
    required super.id,
    required super.title,
    required super.date,
    required super.emoji,
    required super.recurrence,
    super.backgroundColor,
    super.borderColor,
  });

  // --- Construit le modèle depuis un document Firestore ---
  factory ImportantDateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ImportantDateModel(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      emoji: data['emoji'] ?? '',
      recurrence: _recurrenceFrom(data),
      backgroundColor: data['backgroundColor'] ??
          ImportantDateEntity.defaultBackgroundColor,
      borderColor:
          data['borderColor'] ?? ImportantDateEntity.defaultBorderColor,
    );
  }

  // --- Construit le modèle depuis une entité, avant écriture ---
  factory ImportantDateModel.fromEntity(ImportantDateEntity entity) {
    return ImportantDateModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      emoji: entity.emoji,
      recurrence: entity.recurrence,
      backgroundColor: entity.backgroundColor,
      borderColor: entity.borderColor,
    );
  }

  // --- Convertit en map compatible Firestore (l'id n'en fait pas partie).
  // --- La fréquence est enregistrée par son nom : "none", "yearly"... ---
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'emoji': emoji,
      'recurrence': recurrence.name,
      'backgroundColor': backgroundColor,
      'borderColor': borderColor,
    };
  }

  // --- Lit la fréquence d'un document. Un nom inconnu ou absent vaut
  // --- "aucune" ---
  static ImportantDateRecurrence _recurrenceFrom(Map<String, dynamic> data) {
    final name = data['recurrence'];
    for (final recurrence in ImportantDateRecurrence.values) {
      if (recurrence.name == name) return recurrence;
    }

    // --- Ancien format : un simple booléen "repeatsYearly" ---
    return data['repeatsYearly'] == true
        ? ImportantDateRecurrence.yearly
        : ImportantDateRecurrence.none;
  }
}
