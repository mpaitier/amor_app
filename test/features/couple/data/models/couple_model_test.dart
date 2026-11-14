// ============================================================================
// TEST UNITAIRE : CoupleModel (mapping Firestore -> domaine)
// ============================================================================
// fake_cloud_firestore fournit de vrais DocumentSnapshot sans projet
// Firebase.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/couple/data/models/couple_model.dart';
import 'package:amor_app/features/couple/domain/entities/couple_member.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  Future<CoupleModel> modelFrom(Map<String, dynamic> data) async {
    await firestore.collection('couples').doc('couple-1').set(data);
    final doc = await firestore.collection('couples').doc('couple-1').get();
    return CoupleModel.fromFirestore(doc);
  }

  test('reprend les membres dans l\'ordre d\'arrivée, avec leur profil',
      () async {
    final model = await modelFrom({
      'members': ['uid-titi', 'uid-lulu'],
      'profiles': {
        'uid-lulu': {'nickname': 'Lulu', 'color': 0xFFE0A800},
        'uid-titi': {'nickname': 'Titi', 'color': 0xFF7B4FD6},
      },
      'inviteCode': 'K7PQ2A',
    });

    expect(model.id, 'couple-1');
    expect(model.inviteCode, 'K7PQ2A');
    expect(model.members, const [
      CoupleMember(uid: 'uid-titi', nickname: 'Titi', color: 0xFF7B4FD6),
      CoupleMember(uid: 'uid-lulu', nickname: 'Lulu', color: 0xFFE0A800),
    ]);
  });

  test('un membre sans profil reçoit des valeurs par défaut', () async {
    final model = await modelFrom({
      'members': ['uid-titi'],
      'inviteCode': 'K7PQ2A',
    });

    expect(model.members.single.nickname, '');
    expect(model.members.single.color, CoupleModel.fallbackColor);
  });

  test('un document incomplet ne plante pas', () async {
    final model = await modelFrom({'createdBy': 'uid-titi'});

    expect(model.members, isEmpty);
    expect(model.inviteCode, '');
  });
}
