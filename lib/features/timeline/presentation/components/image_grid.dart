// ============================================================================
// IMAGE GRID
// ============================================================================
// Clickable grid of images for one event, with a zoom dialog.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/timeline_event_entity.dart';

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
      itemBuilder: (context, index) => _buildImageTile(context, images[index]),
    );
  }

  // --- Single grid tile, opens a zoom dialog on tap ---
  Widget _buildImageTile(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}