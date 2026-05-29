// <<===========================================================================>>
// <<========================== WIDGET IMAGE CROPPÉE ===========================>>
// <<===========================================================================>>

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';

class CroppedImage extends StatelessWidget {
  // <<--- Paramètres --->
  final String url;
  final int imageCount;
  final double height;

  const CroppedImage({
    super.key,
    required this.url,
    required this.imageCount,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // <<--- Image principale --->
          _buildImage(),

          // <<--- Badge multi-images --->
          if (imageCount > 1) _buildBadge(),
        ],
      ),
    );
  }

  // <<--- Construction de l'image --->
  Widget _buildImage() {
    if (url.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // <<--- État de chargement --->
      placeholder: (context, url) => Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: CircularProgressIndicator(
            color: amorDarkRose,
            strokeWidth: 2,
          ),
        ),
      ),
      // <<--- État d'erreur --->
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  // <<--- Placeholder quand pas d'image --->
  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: Text(
          'Image non disponible',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),
    );
  }

  // <<--- Badge avec le nombre d'images --->
  Widget _buildBadge() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xF3FFDBFB),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_camera,
              color: amorDarkRose,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '$imageCount',
              style: const TextStyle(
                color: amorDarkRose,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}