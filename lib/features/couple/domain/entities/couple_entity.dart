// ============================================================================
// COUPLE ENTITY
// ============================================================================
// La relation : ses membres, dans l'ordre où ils l'ont rejointe, son code
// d'invitation et, le cas échéant, la demande d'arrêt en cours. Pas de
// limite à deux personnes.

import 'couple_end_request.dart';
import 'couple_member.dart';

class CoupleEntity {
  final String id;
  final List<CoupleMember> members;
  final String inviteCode;
  final CoupleEndRequest? endRequest;

  const CoupleEntity({
    required this.id,
    required this.members,
    required this.inviteCode,
    this.endRequest,
  });

  // --- Membre par uid. null si la personne ne fait pas (ou plus) partie
  // --- de la relation ---
  CoupleMember? memberById(String uid) {
    for (final member in members) {
      if (member.uid == uid) return member;
    }
    return null;
  }

  bool hasMember(String uid) => memberById(uid) != null;

  // --- Tout le monde sauf la personne donnée ---
  List<CoupleMember> partnersOf(String uid) {
    return members.where((member) => member.uid != uid).toList();
  }

  // --- Demande d'arrêt : membres actuels qui ont accepté (un ancien membre
  // --- ne compte plus) ---
  int get endAcceptedCount {
    final request = endRequest;
    if (request == null) return 0;
    return members.where((member) => request.hasAccepted(member.uid)).length;
  }

  // --- La demande attend-elle encore la réponse de cette personne ? ---
  bool needsEndAnswerFrom(String uid) {
    final request = endRequest;
    if (request == null || !hasMember(uid)) return false;
    return !request.hasAccepted(uid) && !request.hasDeclined(uid);
  }
}
