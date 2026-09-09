// ============================================================================
// TEST UNITAIRE : TimelineEventModel (mapping Firestore <-> domaine)
// ============================================================================
// DocumentSnapshot est une classe "sealed" du SDK cloud_firestore : elle ne
// peut ni être étendue, ni implémentée, ni mockée directement avec Mock.
// On utilise donc fake_cloud_firestore, qui fait tourner un Firestore en
// mémoire et produit de VRAIS DocumentSnapshot conformes au SDK, sans avoir
// besoin d'un vrai projet Firebase ni de Firebase.initializeApp().

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/timeline/data/models/timeline_event_model.dart';
import 'package:amor_app/features/timeline/domain/entities/timeline_event_entity.dart';

void main() {
  final tDate = DateTime(2024, 5, 20);

  final tEntity = TimelineEventEntity(
    id: 'event_1',
    title: 'Weekend à Rome',
    date: tDate,
    place: 'Rome',
    who: 'Lulu',
    imageUrl: 'url1|url2',
    description: 'Trop bien',
  );

  group('fromEntity', () {
    test('doit copier tous les champs de l\'entité', () {
      final model = TimelineEventModel.fromEntity(tEntity);

      expect(model.id, tEntity.id);
      expect(model.title, tEntity.title);
      expect(model.date, tEntity.date);
      expect(model.place, tEntity.place);
      expect(model.who, tEntity.who);
      expect(model.imageUrl, tEntity.imageUrl);
      expect(model.description, tEntity.description);
    });
  });

  group('toFirestore', () {
    test('doit convertir la date en Timestamp et exclure l\'id', () {
      final model = TimelineEventModel.fromEntity(tEntity);

      final map = model.toFirestore();

      expect(map['title'], 'Weekend à Rome');
      expect(map['date'], Timestamp.fromDate(tDate));
      expect(map['place'], 'Rome');
      expect(map['who'], 'Lulu');
      expect(map['imageUrl'], 'url1|url2');
      expect(map['description'], 'Trop bien');
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
      await firestore.collection('timeline_events').doc('event_42').set({
        'title': 'Randonnée',
        'date': Timestamp.fromDate(tDate),
        'place': 'Chamonix',
        'who': 'Titi',
        'imageUrl': 'url_a',
        'description': 'Super vue',
      });

      final snapshot = await firestore
          .collection('timeline_events')
          .doc('event_42')
          .get();
      final model = TimelineEventModel.fromFirestore(snapshot);

      expect(model.id, 'event_42');
      expect(model.title, 'Randonnée');
      expect(model.date, tDate);
      expect(model.place, 'Chamonix');
      expect(model.who, 'Titi');
      expect(model.imageUrl, 'url_a');
      expect(model.description, 'Super vue');
    });

    test(
        'doit utiliser des chaînes vides par défaut si des champs sont '
        'absents du document', () async {
      await firestore.collection('timeline_events').doc('event_43').set({
        'date': Timestamp.fromDate(tDate),
      });

      final snapshot = await firestore
          .collection('timeline_events')
          .doc('event_43')
          .get();
      final model = TimelineEventModel.fromFirestore(snapshot);

      expect(model.title, '');
      expect(model.place, '');
      expect(model.who, '');
      expect(model.imageUrl, '');
      expect(model.description, '');
    });
  });
}