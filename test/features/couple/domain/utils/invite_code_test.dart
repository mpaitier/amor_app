// ============================================================================
// TEST UNITAIRE : codes et liens d'invitation
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/couple/domain/utils/invite_code.dart';

void main() {
  group('normalizeInviteCode', () {
    test('accepte minuscules, espaces et tirets', () {
      expect(normalizeInviteCode('K7PQ2A'), 'K7PQ2A');
      expect(normalizeInviteCode('k7pq2a'), 'K7PQ2A');
      expect(normalizeInviteCode(' k7p q2a '), 'K7PQ2A');
      expect(normalizeInviteCode('k7p-q2a'), 'K7PQ2A');
    });

    test('refuse une mauvaise longueur', () {
      expect(normalizeInviteCode(''), isNull);
      expect(normalizeInviteCode('K7PQ2'), isNull);
      expect(normalizeInviteCode('K7PQ2AB'), isNull);
    });

    test('refuse les caractères ambigus ou hors alphabet', () {
      expect(normalizeInviteCode('K7PQ20'), isNull);
      expect(normalizeInviteCode('K7PQ2O'), isNull);
      expect(normalizeInviteCode('K7PQ2I'), isNull);
      expect(normalizeInviteCode('K7PQ2!'), isNull);
    });
  });

  test('inviteLinkFor construit le lien Hosting', () {
    expect(
      inviteLinkFor('K7PQ2A'),
      'https://amor-app-9ee55.web.app/join/K7PQ2A',
    );
  });

  group('inviteCodeFromPath', () {
    test('lit le code d\'un chemin /join/', () {
      expect(inviteCodeFromPath('/join/K7PQ2A'), 'K7PQ2A');
      expect(inviteCodeFromPath('/join/k7pq2a'), 'K7PQ2A');
      expect(inviteCodeFromPath('/join/K7PQ2A/'), 'K7PQ2A');
    });

    test('renvoie null pour les autres chemins', () {
      expect(inviteCodeFromPath('/'), isNull);
      expect(inviteCodeFromPath('/settings'), isNull);
      expect(inviteCodeFromPath('/join/'), isNull);
      expect(inviteCodeFromPath('/join/ABC'), isNull);
    });
  });
}
