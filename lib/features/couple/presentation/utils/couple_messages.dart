// ============================================================================
// COUPLE MESSAGES
// ============================================================================
// Phrases affichées autour de la relation : erreurs traduites et
// vérifications faites avant tout appel réseau.

import '../../domain/entities/couple_failure.dart';
import '../../domain/utils/invite_code.dart';

const int nicknameMaxLength = 30;

String coupleFailureMessage(CoupleFailureReason reason) {
  switch (reason) {
    case CoupleFailureReason.invalidCode:
      return 'Ce code ne correspond à aucune relation. Vérifie-le auprès de '
          'la personne qui t\'invite.';
    case CoupleFailureReason.alreadyInCouple:
      return 'Ce compte fait déjà partie d\'une relation.';
    case CoupleFailureReason.invalidProfile:
      return 'Choisis un surnom (au plus $nicknameMaxLength caractères).';
    case CoupleFailureReason.notSignedIn:
      return 'Ta session a expiré. Reconnecte-toi.';
    case CoupleFailureReason.network:
      return 'Pas de connexion internet.';
    case CoupleFailureReason.unknown:
      return 'Une erreur est survenue. Réessaie.';
  }
}

// --- Vérifications locales. null quand tout va bien ---
String? validateNickname(String nickname) {
  final value = nickname.trim();
  if (value.isEmpty) return 'Choisis un surnom.';
  if (value.length > nicknameMaxLength) {
    return 'Au plus $nicknameMaxLength caractères.';
  }
  return null;
}

String? validateInviteCode(String code) {
  if (code.trim().isEmpty) return 'Saisis le code reçu.';
  if (normalizeInviteCode(code) == null) {
    return 'Un code compte $inviteCodeLength caractères, lettres et chiffres.';
  }
  return null;
}
