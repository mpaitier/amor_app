// ============================================================================
// COUPLE SESSION VIEWMODEL
// ============================================================================
// Vit à la racine de l'app. Part de la session de connexion et suit la
// relation de la personne connectée. GoRouter l'écoute pour choisir entre
// connexion, création de relation et journal. onCoupleChanged prévient
// main.dart du changement de relation active, avant les auditeurs, pour que
// les data sources visent la bonne relation quand les écrans s'ouvrent.

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
  final void Function(String? coupleId)? _onCoupleChanged;

  StreamSubscription<CoupleEntity?>? _coupleSubscription;

  // --- State ---
  String? _watchedUid;
  CoupleEntity? _couple;
  bool _isCoupleLoaded = false;
  String? _publishedCoupleId;

  CoupleSessionViewModel({
    required AuthSessionViewModel authSession,
    required WatchCurrentCouple watchCurrentCouple,
    void Function(String? coupleId)? onCoupleChanged,
  })  : _authSession = authSession,
        _watchCurrentCouple = watchCurrentCouple,
        _onCoupleChanged = onCoupleChanged {
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
            _notify();
          },
          // --- Lecture refusée (relation quittée) : plus de relation ---
          onError: (Object _) {
            _couple = null;
            _isCoupleLoaded = true;
            _notify();
          },
        );
      }
    }
    _notify();
  }

  // --- Publie d'abord la relation active, puis prévient les auditeurs ---
  void _notify() {
    final coupleId = this.coupleId;
    if (coupleId != _publishedCoupleId) {
      _publishedCoupleId = coupleId;
      _onCoupleChanged?.call(coupleId);
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
