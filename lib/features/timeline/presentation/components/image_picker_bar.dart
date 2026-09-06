// ============================================================================
// IMAGE PICKER BAR
// ============================================================================
// Gallery (multiple) or camera capture buttons.
// Does NOT upload — only triggers the ViewModel callbacks.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ImagePickerBar extends StatelessWidget {
  final VoidCallback onPickGallery;
  final VoidCallback onTakePhoto;
  final bool isLoading;

  const ImagePickerBar({
    super.key,
    required this.onPickGallery,
    required this.onTakePhoto,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // --- Gallery button ---
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onPickGallery,
            icon: const Icon(Icons.photo_library, color: amorDarkRose),
            label: const Text(
              'Galerie',
              style: TextStyle(color: amorDarkRose),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: amorDarkRose),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // --- Camera button ---
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onTakePhoto,
            icon: const Icon(Icons.camera_alt, color: amorDarkRose),
            label: const Text(
              'Photo',
              style: TextStyle(color: amorDarkRose),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: amorDarkRose),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}