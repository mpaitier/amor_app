// ============================================================================
// TEST UNITAIRE : CoupleEntity
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/couple/domain/entities/couple_entity.dart';
import 'package:amor_app/features/couple/domain/entities/couple_member.dart';

void main() {
  const titi = CoupleMember(uid: 'uid-titi', nickname: 'Titi', color: 1);
  const lulu = CoupleMember(uid: 'uid-lulu', nickname: 'Lulu', color: 2);
  const couple = CoupleEntity(
    id: 'couple-1',
    members: [titi, lulu],
    inviteCode: 'K7PQ2A',
  );

  test('memberById retrouve un membre', () {
    expect(couple.memberById('uid-lulu'), lulu);
    expect(couple.memberById('inconnu'), isNull);
  });

  test('hasMember', () {
    expect(couple.hasMember('uid-titi'), isTrue);
    expect(couple.hasMember('inconnu'), isFalse);
  });

  test('partnersOf exclut la personne donnée', () {
    expect(couple.partnersOf('uid-titi'), [lulu]);
  });

  test('CoupleMember.copyWith garde l\'uid', () {
    final updated = titi.copyWith(nickname: 'Titou');
    expect(updated.uid, 'uid-titi');
    expect(updated.nickname, 'Titou');
    expect(updated.color, 1);
  });
}
