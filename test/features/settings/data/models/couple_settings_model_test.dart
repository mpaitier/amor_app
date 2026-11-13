// ============================================================================
// TEST UNITAIRE : CoupleSettingsModel (mapping Firestore <-> domaine)
// ============================================================================
// Comme pour les autres modèles, fake_cloud_firestore fournit de VRAIS
// DocumentSnapshot sans projet Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/settings/data/models/couple_settings_model.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';
import 'package:amor_app/features/settings/domain/entities/special_day_style.dart';

void main() {
  final tStart = DateTime(2023, 12, 12);
  const tAnniversaryStyle = SpecialDayStyle(
    emoji: '🎉',
    backgroundColor: 0xFFFFF3C4,
    borderColor: 0xFFE0A800,
  );

  final tEntity = CoupleSettingsEntity(
    relationshipStart: tStart,
    showAnniversary: true,
    anniversaryStyle: tAnniversaryStyle,
    showMonthAnniversaries: false,
    gifSearchTerm: 'penguin hug',
  );

  group('toFirestore', () {
    test('doit ranger chaque jour spécial dans sa propre map', () {
      final map = CoupleSettingsModel.fromEntity(tEntity).toFirestore();

      expect(map['relationshipStart'], Timestamp.fromDate(tStart));
      expect(map['anniversary'], {
        'show': true,
        'emoji': '🎉',
        'backgroundColor': 0xFFFFF3C4,
        'borderColor': 0xFFE0A800,
      });
      expect((map['monthAnniversary'] as Map)['show'], isFalse);
      expect(map['gifSearchTerm'], 'penguin hug');
    });
  });

  group('fromFirestore', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    Future<DocumentSnapshot> snapshotOf(Map<String, dynamic>? data) async {
      final reference = firestore.collection('app_settings').doc('couple');
      if (data != null) await reference.set(data);
      return reference.get();
    }

    test('doit relire ce que toFirestore a écrit', () async {
      final snapshot = await snapshotOf(
        CoupleSettingsModel.fromEntity(tEntity).toFirestore(),
      );

      final model = CoupleSettingsModel.fromFirestore(snapshot);

      expect(model.relationshipStart, tStart);
      expect(model.showAnniversary, isTrue);
      expect(model.anniversaryStyle, tAnniversaryStyle);
      expect(model.showMonthAnniversaries, isFalse);
      expect(model.gifSearchTerm, 'penguin hug');
      expect(
        model.monthAnniversaryStyle,
        CoupleSettingsEntity.defaultMonthAnniversaryStyle,
      );
    });

    test('doit donner les réglages d\'origine si le document n\'existe pas',
        () async {
      final snapshot = await snapshotOf(null);

      final model = CoupleSettingsModel.fromFirestore(snapshot);

      expect(model.relationshipStart, DateTime(2023, 12, 12));
      expect(model.showAnniversary, isFalse);
      expect(model.showMonthAnniversaries, isFalse);
    });

    test('doit compléter les champs absents avec les valeurs d\'origine',
        () async {
      final snapshot = await snapshotOf({
        'anniversary': {'show': true},
      });

      final model = CoupleSettingsModel.fromFirestore(snapshot);

      expect(model.relationshipStart, DateTime(2023, 12, 12));
      expect(model.showAnniversary, isTrue);
      expect(
        model.anniversaryStyle,
        CoupleSettingsEntity.defaultAnniversaryStyle,
      );
      expect(model.gifSearchTerm, CoupleSettingsEntity.defaultGifSearchTerm);
    });

    test('doit reprendre le terme d\'origine si le terme stocké est vide',
        () async {
      final snapshot = await snapshotOf({'gifSearchTerm': '   '});

      final model = CoupleSettingsModel.fromFirestore(snapshot);

      expect(model.gifSearchTerm, CoupleSettingsEntity.defaultGifSearchTerm);
    });
  });
}
