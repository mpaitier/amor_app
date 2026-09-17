// ============================================================================
// NAV MENU VIEWMODEL
// ============================================================================
// Contient uniquement l'état du menu (ouvert/fermé) et les règles pour le
// faire évoluer. Aucune dépendance à Flutter au-delà de ChangeNotifier.

import 'package:flutter/foundation.dart';

class NavMenuViewModel extends ChangeNotifier {
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  // --- Ouvre le menu s'il est fermé, le ferme s'il est ouvert ---
  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  // --- Ferme le menu, utilisé après une navigation ---
  void close() {
    if (!_isExpanded) return;
    _isExpanded = false;
    notifyListeners();
  }
}