// ============================================================================
// COUPLE REPOSITORY (INTERFACE)
// ============================================================================
// Contrat de la couche domaine pour la relation. Les méthodes qui échouent
// lèvent une CoupleFailure.

import '../entities/couple_entity.dart';

abstract class CoupleRepository {
  // --- Relation de la personne : null tant qu'elle n'en a pas. Suit en
  // --- temps réel les arrivées, départs et changements de profil ---
  Stream<CoupleEntity?> watchCurrentCouple(String uid);

  // --- Renvoie l'id de la relation créée. La date de début est
  // --- enregistrée dans les réglages de la relation ---
  Future<String> createCouple({
    required String nickname,
    required int color,
    required DateTime relationshipStart,
  });

  // --- Renvoie l'id de la relation rejointe ---
  Future<String> joinCouple({
    required String code,
    required String nickname,
    required int color,
  });

  // --- Fin de relation d'un commun accord. requestEnd et respondToEnd
  // --- renvoient true si la relation vient d'être supprimée ---
  Future<bool> requestEnd();
  Future<bool> respondToEnd({required bool accept});
  Future<void> cancelEnd();

  Future<void> updateMemberProfile({
    required String coupleId,
    required String uid,
    required String nickname,
    required int color,
  });
}
