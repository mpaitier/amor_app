// ============================================================================
// IMAGE REMOTE DATA SOURCE
// ============================================================================
// Compression + upload to Firebase Storage.

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/exceptions.dart';

class ImageRemoteDataSource {
  final FirebaseStorage _storage;
  static const int _compressionQuality = 40;

  const ImageRemoteDataSource({required FirebaseStorage storage})
      : _storage = storage;

  // --- Upload a single image after compression ---
  Future<String?> uploadImage({
    required File imageFile,
    required String folder,
  }) async {
    try {
      final compressedFile = await _compressImage(imageFile);
      if (compressedFile == null) return null;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('$folder/$fileName');

      final uploadTask = await ref.putFile(
        File(compressedFile.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw ImageUploadException('Upload failed: $e');
    }
  }

  // --- Upload several images sequentially ---
  Future<List<String>> uploadImages({
    required List<File> imageFiles,
    required String folder,
  }) async {
    final urls = <String>[];
    for (final file in imageFiles) {
      final url = await uploadImage(imageFile: file, folder: folder);
      if (url != null) urls.add(url);
    }
    return urls;
  }

  // --- Delete an image from its public url ---
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // --- Silently ignore if the image no longer exists ---
    }
  }

  // --- Internal compression helper ---
  Future<XFile?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    final targetPath = path.join(tempDir.path, fileName);

    return FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: _compressionQuality,
      format: CompressFormat.jpeg,
    );
  }
}