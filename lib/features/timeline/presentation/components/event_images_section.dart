// ============================================================================
// EVENT IMAGES SECTION
// ============================================================================
// Combines the picker bar (gallery/camera) with the reorderable image list.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_edit_event_viewmodel.dart';
import 'image_picker_bar.dart';
import 'image_list_editor.dart';

class EventImagesSection extends StatelessWidget {
  const EventImagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditEventViewModel>();
    final pendingCount = viewModel.pendingUploadCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Images',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            // --- Badge showing pending uploads ---
            if (pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingCount en attente',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        ImagePickerBar(
          isLoading: viewModel.isSaving,
          onPickGallery: viewModel.pickFromGallery,
          onTakePhoto: viewModel.takePhotoFromCamera,
        ),
        const SizedBox(height: 12),
        ImageListEditor(
          images: viewModel.imageItems,
          onImagesChanged: viewModel.setImageItems,
        ),
      ],
    );
  }
}