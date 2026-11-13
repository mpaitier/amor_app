// ============================================================================
// SNAPPING BUTTON POSITIONER
// ============================================================================
// Place un bouton flottant à un centre donné, dans un Stack plein écran, et
// remonte les glissers. Le bouton suit le doigt sans délai, puis glisse
// jusqu'au bord quand on le lâche.
//
// Le glisser est lu directement sur les événements du pointeur (Listener)
// et non par un GestureDetector : un appui maintenu avant de bouger
// déclenche un appui long (infobulle, InkWell) qui gagnait l'arène des
// gestes et bloquait le déplacement. Ici, dès que le doigt a bougé de plus
// que la tolérance d'un tap, le bouton suit, quoi qu'il se soit passé avant.
// Le tap du bouton, lui, reste géré par son InkWell.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SnappingButtonPositioner extends StatefulWidget {
  final Offset center;
  final double size;
  final bool isDragging;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;
  final Widget child;

  const SnappingButtonPositioner({
    super.key,
    required this.center,
    required this.isDragging,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
    this.size = 56,
  });

  @override
  State<SnappingButtonPositioner> createState() =>
      _SnappingButtonPositionerState();
}

class _SnappingButtonPositionerState extends State<SnappingButtonPositioner> {
  // --- Pointeur suivi (un seul doigt à la fois) ---
  int? _pointer;
  Offset _travel = Offset.zero;
  bool _moving = false;

  void _onDown(PointerDownEvent event) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    _travel = Offset.zero;
    _moving = false;
  }

  void _onMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;

    if (!_moving) {
      _travel += event.delta;
      if (_travel.distance <= kTouchSlop) return;
      // --- Seuil franchi : on rattrape le chemin déjà parcouru ---
      _moving = true;
      widget.onDragUpdate(_travel);
      return;
    }

    widget.onDragUpdate(event.delta);
  }

  void _onRelease(PointerEvent event) {
    if (event.pointer != _pointer) return;
    if (_moving) widget.onDragEnd();
    _pointer = null;
    _moving = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      // --- Sous le doigt : pas d'animation. Au lâcher : glisse au bord ---
      duration:
          widget.isDragging ? Duration.zero : const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      left: widget.center.dx - widget.size / 2,
      top: widget.center.dy - widget.size / 2,
      child: Listener(
        onPointerDown: _onDown,
        onPointerMove: _onMove,
        onPointerUp: _onRelease,
        onPointerCancel: _onRelease,
        child: widget.child,
      ),
    );
  }
}
