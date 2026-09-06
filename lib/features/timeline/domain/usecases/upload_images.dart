// ============================================================================
// USE CASE: UPLOAD IMAGES
// ============================================================================
// Exposes both a single-file upload (used while iterating pending images)
// and a batch upload (used when every image can be sent at once).

import 'dart:io';
import '../repositories/image_repository.dart';

class UploadImages {
  final ImageRepository _repository;
  const UploadImages(this._repository);

  // --- Upload one image, returns its public url ---
  Future<String?> uploadSingle({
    required File imageFile,
    required String folder,
  }) {
    return _repository.uploadImage(imageFile: imageFile, folder: folder);
  }

  // --- Upload a batch of images, returns the list of public urls ---
  Future<List<String>> call({
    required List<File> imageFiles,
    required String folder,
  }) {
    return _repository.uploadImages(imageFiles: imageFiles, folder: folder);
  }
}