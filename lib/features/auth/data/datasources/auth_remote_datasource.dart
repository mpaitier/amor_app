// ============================================================================
// AUTH REMOTE DATA SOURCE
// ============================================================================
// Seul endroit qui parle à Firebase Auth et à Google Sign-In, plus la Cloud
// Function deleteAccount. Chaque échec ressort en AuthException portant le
// code brut.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../mappers/auth_failure_mapper.dart';
import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFunctions _functions;

  const AuthRemoteDataSource({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseFunctions functions,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _functions = functions;

  // --- Flux de connexion : émet l'état courant dès l'abonnement ---
  Stream<AppUserModel?> watchAuthState() {
    return _auth.authStateChanges().map(
          (user) => user == null ? null : AppUserModel.fromFirebaseUser(user),
        );
  }

  // --- Google : choix du compte, puis échange du jeton contre une
  // --- session Firebase ---
  Future<AppUserModel?> signInWithGoogle() async {
    final account = await _pickGoogleAccount();
    if (account == null) return null;

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _runSignIn(() => _auth.signInWithCredential(credential));
  }

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _runSignIn(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<AppUserModel> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _runSignIn(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.setLanguageCode('fr');
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  // --- La fonction efface le compte, son profil, ses téléphones et, s'il
  // --- était le dernier membre, toute la relation. La session locale, qui
  // --- ne correspond plus à rien, est ensuite fermée ---
  Future<void> deleteAccount() async {
    try {
      await _functions.httpsCallable('deleteAccount').call();
    } on FirebaseFunctionsException catch (e) {
      throw AuthException(e.code == 'unavailable' ? 'network-request-failed' : e.code);
    }
    await signOut();
  }

  // --- Déconnexion Google aussi : sans elle, le prochain "Continuer avec
  // --- Google" reprend le même compte sans proposer le choix ---
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // --- Pas de session Google ouverte : rien à faire ---
    }
    await _auth.signOut();
  }

  // --- Fenêtre de choix du compte Google. null si elle est fermée ---
  Future<GoogleSignInAccount?> _pickGoogleAccount() async {
    try {
      return await _googleSignIn.signIn();
    } on PlatformException catch (e) {
      // --- Certaines versions d'Android signalent l'annulation en erreur ---
      if (e.code == GoogleSignIn.kSignInCanceledError) return null;
      // --- "sign_in_failed" avec ApiException 10 : empreinte SHA-1
      // --- absente de la console Firebase ---
      final isNetwork = e.code == GoogleSignIn.kNetworkError;
      throw AuthException(
        isNetwork ? 'network-request-failed' : googleSignInFailedCode,
      );
    }
  }

  // --- Lance une connexion Firebase et convertit le résultat ---
  Future<AppUserModel> _runSignIn(
    Future<UserCredential> Function() signIn,
  ) async {
    try {
      final credential = await signIn();
      final user = credential.user;
      if (user == null) throw const AuthException('unknown');
      return AppUserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }
}
