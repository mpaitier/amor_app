// ============================================================================
// SNAPPING BUTTON POSITIONER
// ============================================================================
// Place un bouton flottant à un centre donné, dans un Stack plein écran, et
// remonte les glissers. Le bouton suit le doigt sans délai, puis glisse
// jusqu'au bord quand on le lâche. Composant "bête".

import 'package:flutter/material.dart';

class SnappingButtonPositioner extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      // --- Sous le doigt : pas d'animation. Au lâcher : glisse au bord ---
      duration: isDragging ? Duration.zero : const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: GestureDetector(
        onPanUpdate: (details) => onDragUpdate(details.delta),
        onPanEnd: (_) => onDragEnd(),
        onPanCancel: onDragEnd,
        child: child,
      ),
    );
  }
}
