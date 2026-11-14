// ============================================================================
// COUPLE END REQUEST (ENTITY)
// ============================================================================
// Demande d'arrêt de la relation en cours. La relation n'est supprimée que
// lorsque tous les membres actuels ont accepté. Un refus est enregistré pour
// ne plus reposer la question à l'ouverture de l'app ; on peut toujours
// accepter plus tard depuis les paramètres.

class CoupleEndRequest {
  final String requestedBy;
  final DateTime? requestedAt;
  final List<String> acceptedBy;
  final List<String> declinedBy;

  const CoupleEndRequest({
    required this.requestedBy,
    this.requestedAt,
    this.acceptedBy = const [],
    this.declinedBy = const [],
  });

  bool hasAccepted(String uid) => acceptedBy.contains(uid);
  bool hasDeclined(String uid) => declinedBy.contains(uid);
  bool isRequestedBy(String uid) => requestedBy == uid;
}
