// ============================================================================
// USE CASE: PICK IMAGES FROM GALLERY
// ============================================================================

import 'dart:io';
import '../repositories/image_repository.dart';

class PickImagesFromGallery {
  final ImageRepository _repository;
  const PickImagesFromGallery(this._repository);

  Future<List<File>> call() {
    return _repository.pickMultipleFromGallery();
  }
}