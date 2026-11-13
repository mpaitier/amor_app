// ============================================================================
// TEST UNITAIRE : ImportantDateModel (mapping Firestore <-> domaine)
// ============================================================================
// Comme pour TimelineEventModel, on passe par fake_cloud_firestore pour
// obtenir de VRAIS DocumentSnapshot sans projet Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/important_dates/data/models/important_date_model.dart';
import 'package:amor_app/features/important_dates/domain/entities/important_date_entity.dart';

void main() {
  final tDay = DateTime(2026, 12, 28);

  final tEntity = ImportantDateEntity(
    id: 'date_1',
    title: 'Départ à Lisbonne',
    date: tDay,
    emoji: '✈️',
    recurrence: ImportantDateRecurrence.yearly,
    occurrenceLimit: 5,
    backgroundColor: 0xFFD9EAFF,
    borderColor: 0xFF2F6FDE,
  );

  group('fromEntity', () {
    test('doit copier tous les champs de l\'entité', () {
      final model = ImportantDateModel.fromEntity(tEntity);

      expect(model.id, tEntity.id);
      expect(model.title, tEntity.title);
      expect(model.date, tEntity.date);
      expect(model.emoji, tEntity.emoji);
      expect(model.recurrence, tEntity.recurrence);
      expect(model.occurrenceLimit, 5);
      expect(model.backgroundColor, tEntity.backgroundColor);
      expect(model.borderColor, tEntity.borderColor);
    });
  });

  group('toFirestore', () {
    test('doit convertir la date en Timestamp et exclure l\'id', () {
      final model = ImportantDateModel.fromEntity(tEntity);

      final map = model.toFirestore();

      expect(map['title'], 'Départ à Lisbonne');
      expect(map['date'], Timestamp.fromDate(tDay));
      expect(map['emoji'], '✈️');
      expect(map['recurrence'], 'yearly');
      expect(map['occurrenceLimit'], 5);
      expect(map.containsKey('repeatsYearly'), isFalse);
      expect(map['backgroundColor'], 0xFFD9EAFF);
      expect(map['borderColor'], 0xFF2F6FDE);
      expect(map.containsKey('id'), isFalse);
    });
  });

  group('fromFirestore', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('doit reconstruire un modèle complet à partir d\'un document',
        () async {
      await firestore.collection('important_dates').doc('date_42').set({
        'title': 'Noël',
        'date': Timestamp.fromDate(tDay),
        'emoji': '🎄',
        'recurrence': 'monthly',
        'occurrenceLimit': 12,
        'backgroundColor': 0xFFD9F2E0,
        'borderColor': 0xFF2E8B57,
      });

      final snapshot =
          await firestore.collection('important_dates').doc('date_42').get();
      final model = ImportantDateModel.fromFirestore(snapshot);

      expect(model.id, 'date_42');
      expect(model.title, 'Noël');
      expect(model.date, tDay);
      expect(model.emoji, '🎄');
      expect(model.recurrence, ImportantDateRecurrence.monthly);
      expect(model.occurrenceLimit, 12);
      expect(model.backgroundColor, 0xFFD9F2E0);
      expect(model.borderColor, 0xFF2E8B57);
    });

    test(
        'doit utiliser les valeurs par défaut si des champs sont absents du '
        'document', () async {
      await firestore.collection('important_dates').doc('date_43').set({
        'date': Timestamp.fromDate(tDay),
      });

      final snapshot =
          await firestore.collection('important_dates').doc('date_43').get();
      final model = ImportantDateModel.fromFirestore(snapshot);

      expect(model.title, '');
      expect(model.emoji, '');
      expect(model.recurrence, ImportantDateRecurrence.none);
      expect(model.occurrenceLimit, isNull);
      expect(
        model.backgroundColor,
        ImportantDateEntity.defaultBackgroundColor,
      );
      expect(model.borderColor, ImportantDateEntity.defaultBorderColor);
    });

    test('doit ignorer une fréquence inconnue', () async {
      await firestore.collection('important_dates').doc('date_44').set({
        'date': Timestamp.fromDate(tDay),
        'recurrence': 'daily',
      });

      final snapshot =
          await firestore.collection('important_dates').doc('date_44').get();
      final model = ImportantDateModel.fromFirestore(snapshot);

      expect(model.recurrence, ImportantDateRecurrence.none);
    });

    test('doit lire l\'ancien champ repeatsYearly comme une répétition annuelle',
        () async {
      await firestore.collection('important_dates').doc('date_45').set({
        'date': Timestamp.fromDate(tDay),
        'repeatsYearly': true,
      });

      final snapshot =
          await firestore.collection('important_dates').doc('date_45').get();
      final model = ImportantDateModel.fromFirestore(snapshot);

      expect(model.recurrence, ImportantDateRecurrence.yearly);
    });
  });
}
