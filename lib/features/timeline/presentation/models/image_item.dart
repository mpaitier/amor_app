// ============================================================================
// IMAGE ITEM (UI MODEL)
// ============================================================================
// Represents one image inside the add/edit event form.
// - localFile: picked from gallery/camera, not uploaded yet
// - url: already uploaded to Storage (existing event)

import 'dart:io';

class ImageItem {
  final int id;
  final String url;
  final File? localFile;

  const ImageItem({
    required this.id,
    this.url = '',
    this.localFile,
  });

  // --- True if this is a local file not uploaded yet ---
  bool get isPendingUpload => localFile != null;

  ImageItem copyWith({int? id, String? url, File? localFile}) {
    return ImageItem(
      id: id ?? this.id,
      url: url ?? this.url,
      localFile: localFile ?? this.localFile,
    );
  }
}