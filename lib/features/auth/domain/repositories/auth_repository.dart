// ============================================================================
// AUTH REPOSITORY (INTERFACE)
// ============================================================================
// Contrat de la couche domaine pour la connexion. Toutes les méthodes qui
// échouent lèvent une AuthFailure.

import '../entities/app_user.dart';

abstract class AuthRepository {
  // --- Flux de la personne connectée : null quand personne ne l'est.
  // --- Émet l'état courant dès l'abonnement ---
  Stream<AppUser?> watchAuthState();

  // --- Renvoie null si la personne ferme la fenêtre de choix du compte ---
  Future<AppUser?> signInWithGoogle();

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  // --- Suppression définitive du compte, puis déconnexion ---
  Future<void> deleteAccount();
}
