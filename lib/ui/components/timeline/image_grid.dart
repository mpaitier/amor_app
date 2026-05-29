// <<===========================================================================>>
// <<========================= GRILLE D'IMAGES =================================>>
// <<===========================================================================>>
// Équivalent de ImageGrid.kt — grille cliquable des images d'un événement

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/timeline_event.dart';

class ImageGrid extends StatefulWidget {
  // <<--- Paramètres --->
  final TimelineEvent event;

  const ImageGrid({
    super.key,
    required this.event,
  });

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  // <<--- Image sélectionnée pour le zoom --->
  String? _selectedImage;

  @override
  Widget build(BuildContext context) {
    final images = widget.event.getImagesList();

    return Column(
      children: [
        // <<--- Grille d'images --->
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return _buildImageTile(images[index]);
          },
        ),

        // <<--- Dialog zoom image --->
        if (_selectedImage != null) ...[
          GestureDetector(
            onTap: () => setState(() => _selectedImage = null),
            child: Dialog(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: _selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // <<--- Tuile individuelle de la grille --->
  Widget _buildImageTile(String imageUrl) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}