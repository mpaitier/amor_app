// ============================================================================
// IMAGE VIEWER PAGE
// ============================================================================
// Une page de la visionneuse : l'image entière, centrée. Un appui à côté de
// l'image ferme la visionneuse ; un appui sur l'image ne fait rien.
// Composant "bête".

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onBackgroundTap;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
    required this.onBackgroundTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onBackgroundTap,
      child: Center(
        child: Padding(
          // --- Place laissée aux flèches de chaque côté ---
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: GestureDetector(
            // --- Absorbe l'appui pour ne pas fermer en touchant l'image ---
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white70,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
