// ============================================================================
// AUTH MESSAGES
// ============================================================================
// Phrases affichées sur l'écran de connexion : erreurs Firebase traduites
// et vérifications du formulaire faites avant tout appel réseau.

import '../../domain/entities/auth_failure.dart';

// --- Longueur minimale imposée par Firebase Auth par défaut ---
const int minPasswordLength = 6;

String authFailureMessage(AuthFailureReason reason) {
  switch (reason) {
    case AuthFailureReason.invalidEmail:
      return 'Cette adresse e-mail n\'a pas l\'air valide.';
    case AuthFailureReason.wrongCredentials:
      return 'E-mail ou mot de passe incorrect.';
    case AuthFailureReason.emailAlreadyInUse:
      return 'Un compte existe déjà avec cette adresse. Connecte-toi plutôt.';
    case AuthFailureReason.weakPassword:
      return 'Mot de passe trop faible : au moins $minPasswordLength caractères.';
    case AuthFailureReason.tooManyRequests:
      return 'Trop de tentatives. Réessaie dans quelques minutes.';
    case AuthFailureReason.network:
      return 'Pas de connexion internet.';
    case AuthFailureReason.accountExistsWithOtherMethod:
      return 'Cette adresse est déjà liée à une autre méthode de connexion.';
    case AuthFailureReason.userDisabled:
      return 'Ce compte a été désactivé.';
    case AuthFailureReason.googleSignInFailed:
      return 'La connexion Google a échoué.';
    case AuthFailureReason.unknown:
      return 'Une erreur est survenue. Réessaie.';
  }
}

// --- Vérifications locales. null quand tout va bien ---
String? validateEmail(String email) {
  final value = email.trim();
  if (value.isEmpty) return 'Indique ton adresse e-mail.';
  if (!value.contains('@') || !value.contains('.')) {
    return 'Cette adresse e-mail n\'a pas l\'air valide.';
  }
  return null;
}

String? validatePassword(String password, {required bool isRegistering}) {
  if (password.isEmpty) return 'Indique ton mot de passe.';
  if (isRegistering && password.length < minPasswordLength) {
    return 'Au moins $minPasswordLength caractères.';
  }
  return null;
}

String? validateConfirmation(String password, String confirmation) {
  if (confirmation != password) {
    return 'Les deux mots de passe ne correspondent pas.';
  }
  return null;
}
