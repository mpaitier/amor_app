// ============================================================================
// EVENT TITLE FIELD
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_edit_event_viewmodel.dart';

class EventTitleField extends StatelessWidget {
  const EventTitleField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AddEditEventViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: viewModel.titleController,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          hintText: 'Titre...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }
}