// ============================================================================
// EVENT SAVE LOADING OVERLAY
// ============================================================================
// Shown while pending images are uploading and the event is being saved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/add_edit_event_viewmodel.dart';

class EventSaveLoadingOverlay extends StatelessWidget {
  const EventSaveLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditEventViewModel>();
    final pendingCount = viewModel.pendingUploadCount;

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: amorDarkRose),
                const SizedBox(height: 16),
                Text(
                  pendingCount > 0
                      ? 'Upload de $pendingCount image(s)...'
                      : 'Synchronisation...',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}