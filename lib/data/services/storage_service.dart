// <<===========================================================================>>
// <<====================== SERVICE FIREBASE STORAGE ===========================>>
// <<===========================================================================>>
// Upload d'images avec compression 40% vers Firebase Storage

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class StorageService {
  // <<--- Instance Firebase Storage --->
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // <<--- Upload d'une image avec compression 40% --->
  static Future<String?> uploadImage({
    required File imageFile,
    required String folder,
  }) async {
    try {
      // <<--- Compression à 40% de qualité --->
      final compressedFile = await _compressImage(imageFile);
      if (compressedFile == null) return null;

      // <<--- Nom unique basé sur le timestamp --->
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('$folder/$fileName');

      // <<--- Upload vers Firebase Storage --->
      final uploadTask = await ref.putFile(
        File(compressedFile.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // <<--- Récupération de l'URL publique --->
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // <<--- Upload multiple (galerie) --->
  static Future<List<String>> uploadImages({
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

  // <<--- Compression interne à 40% --->
  static Future<XFile?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    final targetPath = path.join(tempDir.path, fileName);

    return FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      // <<--- Qualité 40% --->
      quality: 40,
      format: CompressFormat.jpeg,
    );
  }

  // <<--- Suppression d'une image depuis son URL --->
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // <<--- Silencieux si l'image n'existe plus --->
    }
  }
}