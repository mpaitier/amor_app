// <<===========================================================================>>
// <<====================== BARRE DE SÉLECTION D'IMAGES ========================>>
// <<===========================================================================>>
// Sélection depuis la galerie (multiple) ou prise de photo
// <<--- NE FAIT PAS D'UPLOAD — retourne juste les File locaux --->

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/photo_service.dart';

class ImagePickerBar extends StatelessWidget {
  final void Function(List<File> files) onImagesPicked;
  final bool isLoading;

  const ImagePickerBar({
    super.key,
    required this.onImagesPicked,
    this.isLoading = false,
  });

  static final PhotoService _photoService = PhotoService();

  // <<--- Sélection galerie : retourne les File, sans uploader --->
  Future<void> _pickFromGallery() async {
    final files = await _photoService.choisirPlusieursPhotos();
    if (files.isNotEmpty) onImagesPicked(files);
  }

  // <<--- Prise de photo : retourne le File, sans uploader --->
  Future<void> _takePhoto() async {
    final file = await _photoService.prendrePhoto();
    if (file != null) onImagesPicked([file]);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // <<--- Bouton Galerie --->
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : _pickFromGallery,
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

        // <<--- Bouton Caméra --->
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : _takePhoto,
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