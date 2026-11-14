// ============================================================================
// IMAGE GRID
// ============================================================================
// Grille cliquable des images d'un souvenir. Un appui ouvre la visionneuse
// sur l'image touchée.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/timeline_event_entity.dart';
import 'image_viewer_dialog.dart';

class ImageGrid extends StatelessWidget {
  final TimelineEventEntity event;

  const ImageGrid({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final images = event.imagesList;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) =>
          _buildImageTile(context, images, index),
    );
  }

  // --- Vignette de la grille, ouvre la visionneuse sur elle-même ---
  Widget _buildImageTile(
    BuildContext context,
    List<String> images,
    int index,
  ) {
    return GestureDetector(
      onTap: () => ImageViewerDialog.show(
        context,
        imageUrls: images,
        initialIndex: index,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(imageUrl: images[index], fit: BoxFit.cover),
      ),
    );
  }
}
