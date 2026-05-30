// <<===========================================================================>>
// <<=================== ÉDITEUR DE LISTE D'IMAGES =============================>>
// <<===========================================================================>>

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

// <<--- Modèle d'un item image --->
// <<--- localFile = photo pas encore uploadée (sélectionnée depuis galerie/caméra) --->
// <<--- url = photo déjà uploadée sur Storage (event existant) --->
class ImageItem {
  final int id;
  String url;
  final File? localFile;

  ImageItem({
    required this.id,
    this.url = '',
    this.localFile,
  });

  // <<--- True si c'est un fichier local pas encore uploadé --->
  bool get isPendingUpload => localFile != null;
}

class ImageListEditor extends StatefulWidget {
  final List<ImageItem> images;
  final void Function(List<ImageItem> updated) onImagesChanged;

  const ImageListEditor({
    super.key,
    required this.images,
    required this.onImagesChanged,
  });

  @override
  State<ImageListEditor> createState() => _ImageListEditorState();
}

class _ImageListEditorState extends State<ImageListEditor> {

  void _removeAt(int index) {
    final updated = List<ImageItem>.from(widget.images)..removeAt(index);
    widget.onImagesChanged(updated);
  }

  void _moveUp(int index) {
    if (index <= 0) return;
    final updated = List<ImageItem>.from(widget.images);
    final item = updated.removeAt(index);
    updated.insert(index - 1, item);
    widget.onImagesChanged(updated);
  }

  void _moveDown(int index) {
    if (index >= widget.images.length - 1) return;
    final updated = List<ImageItem>.from(widget.images);
    final item = updated.removeAt(index);
    updated.insert(index + 1, item);
    widget.onImagesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.images;

    if (items.isEmpty) {
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
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final updated = List<ImageItem>.from(items);
        final item = updated.removeAt(oldIndex);
        updated.insert(newIndex, item);
        widget.onImagesChanged(updated);
      },
      itemBuilder: (context, index) {
        return _buildImageTile(index, items[index]);
      },
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
          // <<--- Miniature (locale ou réseau) --->
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: _buildThumbnail(item),
          ),

          const SizedBox(width: 10),

          // <<--- Numéro + label --->
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
                // <<--- Affiche le nom du fichier ou l'URL selon le cas --->
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
                // <<--- Badge "En attente d'upload" --->
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

          // <<--- Boutons haut / bas --->
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
                onPressed: index < widget.images.length - 1
                    ? () => _moveDown(index)
                    : null,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: index < widget.images.length - 1
                      ? amorDarkRose
                      : Colors.grey.withValues(alpha: 0.3),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          // <<--- Supprimer (supprime juste de la liste locale, pas de Storage) --->
          IconButton(
            onPressed: () => _removeAt(index),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: const EdgeInsets.only(right: 4),
          ),

          // <<--- Poignée drag --->
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
    // <<--- Fichier local : on affiche directement depuis le disque --->
    if (item.isPendingUpload) {
      return Image.file(
        item.localFile!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      );
    }

    // <<--- URL vide --->
    if (item.url.isEmpty) {
      return Container(
        width: 64,
        height: 64,
        color: const Color(0xFFF5F5F5),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    // <<--- URL réseau (image déjà sur Storage) --->
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
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: amorDarkRose,
            ),
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