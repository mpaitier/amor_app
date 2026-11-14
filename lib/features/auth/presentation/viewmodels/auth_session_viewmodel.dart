// ============================================================================
// AUTH SESSION VIEWMODEL
// ============================================================================
// Vit à la racine de l'app. Suit en temps réel qui est connecté ; GoRouter
// l'écoute pour envoyer vers l'écran de connexion ou vers le journal.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';

enum AuthStatus {
  // --- Firebase n'a pas encore répondu (lancement de l'app) ---
  unknown,
  signedOut,
  signedIn,
}

class AuthSessionViewModel extends ChangeNotifier {
  final WatchAuthState _watchAuthState;
  final SignOut _signOut;

  StreamSubscription<AppUser?>? _subscription;

  // --- State ---
  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;

  AuthSessionViewModel({
    required WatchAuthState watchAuthState,
    required SignOut signOut,
  })  : _watchAuthState = watchAuthState,
        _signOut = signOut {
    _listen();
  }

  // --- Getters ---
  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isSignedIn => _status == AuthStatus.signedIn;

  void _listen() {
    _subscription = _watchAuthState().listen(
      (user) {
        _user = user;
        _status = user == null ? AuthStatus.signedOut : AuthStatus.signedIn;
        notifyListeners();
      },
      // --- Flux en erreur : on renvoie vers la connexion plutôt que de
      // --- rester bloqué sur l'écran de chargement ---
      onError: (Object _) {
        _user = null;
        _status = AuthStatus.signedOut;
        notifyListeners();
      },
    );
  }

  // --- La redirection suit d'elle-même, via le flux ---
  Future<void> signOut() => _signOut();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
