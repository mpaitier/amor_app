// ============================================================================
// USE CASE: TAKE PHOTO
// ============================================================================

import 'dart:io';
import '../repositories/image_repository.dart';

class TakePhoto {
  final ImageRepository _repository;
  const TakePhoto(this._repository);

  Future<File?> call() {
    return _repository.takePhoto();
  }
}