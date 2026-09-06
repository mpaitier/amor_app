// ============================================================================
// IMAGE LIST EDITOR
// ============================================================================
// Reorderable list of ImageItem: move up/down, drag handle, remove,
// thumbnail preview (local file or network url).

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/image_item.dart';

class ImageListEditor extends StatelessWidget {
  final List<ImageItem> images;
  final void Function(List<ImageItem> updated) onImagesChanged;

  const ImageListEditor({
    super.key,
    required this.images,
    required this.onImagesChanged,
  });

  void _removeAt(int index) {
    final updated = List<ImageItem>.from(images)..removeAt(index);
    onImagesChanged(updated);
  }

  void _moveUp(int index) {
    if (index <= 0) return;
    final updated = List<ImageItem>.from(images);
    final item = updated.removeAt(index);
    updated.insert(index - 1, item);
    onImagesChanged(updated);
  }

  void _moveDown(int index) {
    if (index >= images.length - 1) return;
    final updated = List<ImageItem>.from(images);
    final item = updated.removeAt(index);
    updated.insert(index + 1, item);
    onImagesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: amorCreamTransparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Text(
            'Aucune image ajoutée',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final updated = List<ImageItem>.from(images);
        final item = updated.removeAt(oldIndex);
        updated.insert(newIndex, item);
        onImagesChanged(updated);
      },
      itemBuilder: (context, index) => _buildImageTile(index, images[index]),
    );
  }

  Widget _buildImageTile(int index, ImageItem item) {
    return Container(
      key: ValueKey(item.id),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- Thumbnail (local or network) ---
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: _buildThumbnail(item),
          ),

          const SizedBox(width: 10),

          // --- Number + label ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: amorDarkRose,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.isPendingUpload
                      ? item.localFile!.path.split('/').last
                      : item.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: item.isPendingUpload
                        ? Colors.orange.shade700
                        : Colors.grey,
                  ),
                ),
                if (item.isPendingUpload)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 10,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Sera uploadée à l\'enregistrement',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // --- Up / down buttons ---
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: index > 0 ? () => _moveUp(index) : null,
                icon: Icon(
                  Icons.keyboard_arrow_up,
                  color: index > 0
                      ? amorDarkRose
                      : Colors.grey.withValues(alpha: 0.3),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed:
                    index < images.length - 1 ? () => _moveDown(index) : null,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: index < images.length - 1
                      ? amorDarkRose
                      : Colors.grey.withValues(alpha: 0.3),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          // --- Delete (removes from the local list only, not Storage) ---
          IconButton(
            onPressed: () => _removeAt(index),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: const EdgeInsets.only(right: 4),
          ),

          // --- Drag handle ---
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.drag_handle, color: Colors.grey, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ImageItem item) {
    // --- Local file: display directly from disk ---
    if (item.isPendingUpload) {
      return Image.file(
        item.localFile!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      );
    }

    // --- Empty url ---
    if (item.url.isEmpty) {
      return Container(
        width: 64,
        height: 64,
        color: const Color(0xFFF5F5F5),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    // --- Network url (already on Storage) ---
    return CachedNetworkImage(
      imageUrl: item.url,
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: 64,
        height: 64,
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: amorDarkRose),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        width: 64,
        height: 64,
        color: const Color(0xFFF5F5F5),
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}