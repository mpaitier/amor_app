// ============================================================================
// COUPLE FAILURE (ENTITY)
// ============================================================================
// Échec à la création d'une relation, à l'adhésion ou à la mise à jour
// d'un profil, exprimé sans vocabulaire Firebase.

enum CoupleFailureReason {
  invalidCode,
  alreadyInCouple,
  invalidProfile,
  notSignedIn,
  network,
  unknown,
}

class CoupleFailure implements Exception {
  final CoupleFailureReason reason;

  const CoupleFailure(this.reason);

  @override
  String toString() => 'CoupleFailure(${reason.name})';
}
