// ============================================================================
// EVENT DESCRIPTION FIELD
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/add_edit_event_viewmodel.dart';

class EventDescriptionField extends StatelessWidget {
  const EventDescriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AddEditEventViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: amorCream,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: viewModel.descriptionController,
        minLines: 4,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Raconte-moi...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }
}