// ============================================================================
// IMAGE REPOSITORY (INTERFACE)
// ============================================================================
// Covers both local image selection (gallery/camera) and remote upload.

import 'dart:io';

abstract class ImageRepository {
  // --- Pick multiple images from the gallery ---
  Future<List<File>> pickMultipleFromGallery();

  // --- Take a single photo with the camera ---
  Future<File?> takePhoto();

  // --- Upload a single image, returns its public url ---
  Future<String?> uploadImage({
    required File imageFile,
    required String folder,
  });

  // --- Upload several images, returns the list of public urls ---
  Future<List<String>> uploadImages({
    required List<File> imageFiles,
    required String folder,
  });

  // --- Delete an image from remote storage ---
  Future<void> deleteImage(String imageUrl);
}