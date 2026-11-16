// ============================================================================
// APP UPDATE VIEWMODEL
// ============================================================================
// Vérifie une fois, au lancement, si une version plus récente est publiée.
// Vit pour toute la durée de l'app (fourni par main.dart) : revenir sur
// l'écran principal ne relance ni la vérification ni la fenêtre. La
// fenêtre n'est montrée qu'une fois par lancement ; "Plus tard" repose
// donc la question à l'ouverture suivante.

import 'package:flutter/foundation.dart';
import '../../domain/entities/app_update.dart';
import '../../domain/usecases/check_for_update.dart';

class AppUpdateViewModel extends ChangeNotifier {
  final CheckForUpdate _checkForUpdate;

  AppUpdate? _update;
  bool _isChecking = false;
  bool _wasPrompted = false;

  AppUpdateViewModel({required CheckForUpdate checkForUpdate})
      : _checkForUpdate = checkForUpdate;

  // --- Mise à jour trouvée, tant que la fenêtre n'a pas été montrée ---
  AppUpdate? get pendingUpdate => _wasPrompted ? null : _update;

  // --- Mise à jour trouvée, même après la fenêtre ---
  AppUpdate? get availableUpdate => _update;

  Future<void> check() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      _update = await _checkForUpdate();
    } catch (e) {
      // --- Une vérification ratée ne doit rien empêcher ---
      debugPrint('[Mise à jour] Vérification impossible : $e');
      _update = null;
    } finally {
      _isChecking = false;
    }
    notifyListeners();
  }

  // --- La fenêtre a été montrée pendant ce lancement ---
  void markPrompted() {
    _wasPrompted = true;
  }
}
