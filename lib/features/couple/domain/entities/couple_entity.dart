// ============================================================================
// COUPLE ENTITY
// ============================================================================
// La relation : ses membres, dans l'ordre où ils l'ont rejointe, et son
// code d'invitation. Pas de limite à deux personnes.

import 'couple_member.dart';

class CoupleEntity {
  final String id;
  final List<CoupleMember> members;
  final String inviteCode;

  const CoupleEntity({
    required this.id,
    required this.members,
    required this.inviteCode,
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
}
