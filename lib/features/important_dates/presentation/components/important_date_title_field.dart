// ============================================================================
// IMPORTANT DATE TITLE FIELD
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';

class ImportantDateTitleField extends StatelessWidget {
  const ImportantDateTitleField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AddEditImportantDateViewModel>();

    return TextField(
      controller: viewModel.titleController,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: 'Titre',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: _border(outlineLight, 1),
        focusedBorder: _border(amorDarkRose, 2),
      ),
    );
  }

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
