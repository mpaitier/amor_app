// ============================================================================
// IMAGE LOCAL DATA SOURCE
// ============================================================================
// Device-side image selection (camera / gallery). Does NOT upload.

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/exceptions.dart';

class ImageLocalDataSource {
  final ImagePicker _picker;
  static const int _pickQuality = 25;

  ImageLocalDataSource({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  // --- Take a single photo with the camera ---
  Future<File?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: _pickQuality,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw ImagePickException('Camera capture failed: $e');
    }
  }

  // --- Pick multiple photos from the gallery ---
  Future<List<File>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: _pickQuality,
      );
      return images.map((img) => File(img.path)).toList();
    } catch (e) {
      throw ImagePickException('Gallery selection failed: $e');
    }
  }
}