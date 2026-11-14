// ============================================================================
// COUPLE FAILURE MAPPER
// ============================================================================
// Traduit les codes renvoyés par les Cloud Functions (HttpsError) et par
// Firestore en raisons du domaine.

import '../../domain/entities/couple_failure.dart';

CoupleFailureReason coupleFailureReasonFromCode(String code) {
  switch (code) {
    case 'not-found':
      return CoupleFailureReason.invalidCode;
    case 'already-exists':
      return CoupleFailureReason.alreadyInCouple;
    case 'invalid-argument':
      return CoupleFailureReason.invalidProfile;
    case 'unauthenticated':
      return CoupleFailureReason.notSignedIn;
    case 'unavailable':
    case 'deadline-exceeded':
      return CoupleFailureReason.network;
    default:
      return CoupleFailureReason.unknown;
  }
}
