// ============================================================================
// TEST UNITAIRE : CoupleEntity
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/couple/domain/entities/couple_entity.dart';
import 'package:amor_app/features/couple/domain/entities/couple_member.dart';
import 'package:amor_app/features/couple/domain/entities/couple_end_request.dart';

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

  group('demande d\'arrêt', () {
    const withRequest = CoupleEntity(
      id: 'couple-1',
      members: [titi, lulu],
      inviteCode: 'K7PQ2A',
      endRequest: CoupleEndRequest(
        requestedBy: 'uid-titi',
        acceptedBy: ['uid-titi', 'uid-parti'],
      ),
    );

    test('endAcceptedCount ne compte que les membres actuels', () {
      expect(withRequest.endAcceptedCount, 1);
      expect(couple.endAcceptedCount, 0);
    });

    test('needsEndAnswerFrom : seulement sans réponse', () {
      expect(withRequest.needsEndAnswerFrom('uid-lulu'), isTrue);
      expect(withRequest.needsEndAnswerFrom('uid-titi'), isFalse);
      expect(withRequest.needsEndAnswerFrom('inconnu'), isFalse);
      expect(couple.needsEndAnswerFrom('uid-lulu'), isFalse);
    });

    test('un refus ne repose plus la question', () {
      const declined = CoupleEntity(
        id: 'couple-1',
        members: [titi, lulu],
        inviteCode: 'K7PQ2A',
        endRequest: CoupleEndRequest(
          requestedBy: 'uid-titi',
          acceptedBy: ['uid-titi'],
          declinedBy: ['uid-lulu'],
        ),
      );
      expect(declined.needsEndAnswerFrom('uid-lulu'), isFalse);
      expect(declined.endRequest!.hasDeclined('uid-lulu'), isTrue);
      expect(declined.endRequest!.isRequestedBy('uid-titi'), isTrue);
    });
  });
}
