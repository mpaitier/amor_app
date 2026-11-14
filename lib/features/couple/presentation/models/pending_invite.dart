// ============================================================================
// PENDING INVITE (UI MODEL)
// ============================================================================
// Code reçu par un lien d'invitation, gardé le temps que la personne se
// connecte. Le routeur le dépose, l'écran de création de relation le
// reprend pour pré-remplir le champ.

import 'package:flutter/foundation.dart';

class PendingInvite extends ChangeNotifier {
  String? _code;

  String? get code => _code;

  void remember(String code) {
    if (_code == code) return;
    _code = code;
    notifyListeners();
  }

  void clear() {
    if (_code == null) return;
    _code = null;
    notifyListeners();
  }
}
