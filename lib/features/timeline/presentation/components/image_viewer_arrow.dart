// ============================================================================
// IMAGE VIEWER ARROW
// ============================================================================
// Flèche discrète de la visionneuse : juste la pointe (< ou >), blanche avec
// une ombre légère pour rester lisible sur une photo claire. Composant
// "bête" : reçoit son sens et son callback.

import 'package:flutter/material.dart';

enum ImageViewerArrowDirection { previous, next }

class ImageViewerArrow extends StatelessWidget {
  final ImageViewerArrowDirection direction;
  final VoidCallback onPressed;

  const ImageViewerArrow({
    super.key,
    required this.direction,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isPrevious = direction == ImageViewerArrowDirection.previous;

    return IconButton(
      onPressed: onPressed,
      tooltip: isPrevious ? 'Image précédente' : 'Image suivante',
      iconSize: 36,
      icon: Icon(
        isPrevious ? Icons.chevron_left : Icons.chevron_right,
        color: Colors.white.withValues(alpha: 0.85),
        shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
      ),
    );
  }
}
