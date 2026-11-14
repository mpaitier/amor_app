// ============================================================================
// COUPLE SESSION VIEWMODEL
// ============================================================================
// Vit à la racine de l'app. Part de la session de connexion et suit la
// relation de la personne connectée. GoRouter l'écoute pour choisir entre
// connexion, création de relation et journal.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/viewmodels/auth_session_viewmodel.dart';
import '../../domain/entities/couple_entity.dart';
import '../../domain/entities/couple_member.dart';
import '../../domain/usecases/watch_current_couple.dart';

enum SessionStatus {
  // --- Connexion ou relation pas encore connues ---
  loading,
  signedOut,
  // --- Connecté, sans relation : création ou adhésion à faire ---
  needsCouple,
  ready,
}

class CoupleSessionViewModel extends ChangeNotifier {
  final AuthSessionViewModel _authSession;
  final WatchCurrentCouple _watchCurrentCouple;

  StreamSubscription<CoupleEntity?>? _coupleSubscription;

  // --- State ---
  String? _watchedUid;
  CoupleEntity? _couple;
  bool _isCoupleLoaded = false;

  CoupleSessionViewModel({
    required AuthSessionViewModel authSession,
    required WatchCurrentCouple watchCurrentCouple,
  })  : _authSession = authSession,
        _watchCurrentCouple = watchCurrentCouple {
    _authSession.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  // --- Getters ---
  AppUser? get user => _authSession.user;
  CoupleEntity? get couple => _hasCouple ? _couple : null;
  String? get coupleId => couple?.id;

  // --- Profil de la personne connectée dans sa relation ---
  CoupleMember? get me {
    final uid = user?.uid;
    if (uid == null) return null;
    return couple?.memberById(uid);
  }

  SessionStatus get status {
    switch (_authSession.status) {
      case AuthStatus.unknown:
        return SessionStatus.loading;
      case AuthStatus.signedOut:
        return SessionStatus.signedOut;
      case AuthStatus.signedIn:
        if (!_isCoupleLoaded) return SessionStatus.loading;
        return _hasCouple ? SessionStatus.ready : SessionStatus.needsCouple;
    }
  }

  // --- Une relation dont la personne ne fait plus partie ne compte pas ---
  bool get _hasCouple {
    final uid = user?.uid;
    return uid != null && _couple != null && _couple!.hasMember(uid);
  }

  // --- À chaque changement de compte, on suit la relation du nouveau ---
  void _onAuthChanged() {
    final uid = _authSession.user?.uid;
    if (uid != _watchedUid) {
      _coupleSubscription?.cancel();
      _coupleSubscription = null;
      _watchedUid = uid;
      _couple = null;
      _isCoupleLoaded = false;

      if (uid != null) {
        _coupleSubscription = _watchCurrentCouple(uid).listen(
          (couple) {
            _couple = couple;
            _isCoupleLoaded = true;
            notifyListeners();
          },
          // --- Lecture refusée (relation quittée) : plus de relation ---
          onError: (Object _) {
            _couple = null;
            _isCoupleLoaded = true;
            notifyListeners();
          },
        );
      }
    }
    notifyListeners();
  }

  Future<void> signOut() => _authSession.signOut();

  @override
  void dispose() {
    _authSession.removeListener(_onAuthChanged);
    _coupleSubscription?.cancel();
    super.dispose();
  }
}
