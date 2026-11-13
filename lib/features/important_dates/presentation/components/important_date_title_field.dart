// ============================================================================
// IMPORTANT DATE TITLE FIELD
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';

class ImportantDateTitleField extends StatelessWidget {
  const ImportantDateTitleField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AddEditImportantDateViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: viewModel.titleController,
        textCapitalization: TextCapitalization.sentences,
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
