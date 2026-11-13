// ============================================================================
// FLOATING BUTTONS VIEWMODEL
// ============================================================================
// Position des deux boutons flottants (pages et ajout), partagée par tous
// les écrans. Gardée en mémoire seulement : chaque lancement de l'app repart
// des positions de départ. Pendant un glisser, le bouton suit le doigt ; au
// lâcher, il se colle au bord le plus proche.

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../models/floating_button_position.dart';

enum FloatingButtonId { navigation, add }

class FloatingButtonsViewModel extends ChangeNotifier {
  final Map<FloatingButtonId, FloatingButtonPosition> _positions = {
    FloatingButtonId.navigation: FloatingButtonPosition.navigationDefault,
    FloatingButtonId.add: FloatingButtonPosition.addDefault,
  };

  // --- Centre suivi pendant un glisser, absent sinon ---
  final Map<FloatingButtonId, Offset> _dragCenters = {};

  FloatingButtonPosition positionOf(FloatingButtonId id) => _positions[id]!;

  bool isDragging(FloatingButtonId id) => _dragCenters.containsKey(id);

  // --- Centre à afficher : sous le doigt pendant un glisser, sur le bord
  // --- sinon ---
  Offset centerOf(FloatingButtonId id, Size area) {
    return _dragCenters[id] ?? positionOf(id).centerIn(area);
  }

  // --- Le doigt bouge : le bouton suit, sans sortir de l'écran ---
  void drag(FloatingButtonId id, Offset delta, Size area) {
    final start = centerOf(id, area);
    final moved = start + delta;
    _dragCenters[id] = Offset(
      moved.dx.clamp(0.0, area.width),
      moved.dy.clamp(0.0, area.height),
    );
    notifyListeners();
  }

  // --- Le doigt se lève : le bouton se colle au bord le plus proche ---
  void endDrag(FloatingButtonId id, Size area) {
    final center = _dragCenters.remove(id);
    if (center == null) return;
    _positions[id] = FloatingButtonPosition.snap(center, area);
    notifyListeners();
  }
}
