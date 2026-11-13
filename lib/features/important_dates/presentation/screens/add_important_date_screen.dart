// ============================================================================
// ADD / EDIT IMPORTANT DATE SCREEN
// ============================================================================
// Formulaire d'une date importante : titre, jour, répétition, emoji et
// couleurs de la case, avec un aperçu.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/important_date_entity.dart';
import '../components/important_date_color_picker.dart';
import '../components/important_date_date_card.dart';
import '../components/important_date_emoji_picker.dart';
import '../components/important_date_form_section.dart';
import '../components/important_date_preview.dart';
import '../components/important_date_title_field.dart';
import '../models/important_date_palette.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';

class AddImportantDateScreen extends StatelessWidget {
  final ImportantDateEntity? dateToEdit;

  const AddImportantDateScreen({super.key, this.dateToEdit});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddEditImportantDateViewModel(
        addImportantDate: sl.addImportantDate,
        updateImportantDate: sl.updateImportantDate,
        dateToEdit: dateToEdit,
      ),
      child: const _AddImportantDateView(),
    );
  }
}

class _AddImportantDateView extends StatelessWidget {
  const _AddImportantDateView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, viewModel),
      body: _buildForm(viewModel),
    );
  }

  // --- App bar avec l'action d'enregistrement ---
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AddEditImportantDateViewModel viewModel,
  ) {
    return AppBar(
      backgroundColor: amorCreamTransparent,
      title: Text(
        viewModel.isEditing ? 'Modifier la date' : 'Ajouter une date',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: amorDarkRose,
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        TextButton(
          onPressed:
              viewModel.isSaving ? null : () => _handleSave(context, viewModel),
          child: Text(
            'Enregistrer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: viewModel.isSaving ? Colors.grey : amorDarkRose,
            ),
          ),
        ),
      ],
    );
  }

  // --- Formulaire défilant ---
  Widget _buildForm(AddEditImportantDateViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        const ImportantDateTitleField(),
        const SizedBox(height: 12),
        const ImportantDateDateCard(),
        const SizedBox(height: 12),
        const ImportantDateFormSection(
          label: 'Emoji',
          child: ImportantDateEmojiPicker(),
        ),
        const SizedBox(height: 12),
        ImportantDateFormSection(
          label: 'Fond de la case',
          child: ImportantDateColorPicker(
            colors: ImportantDatePalette.backgroundColors,
            selectedColor: viewModel.backgroundColor,
            onColorSelected: viewModel.setBackgroundColor,
          ),
        ),
        const SizedBox(height: 12),
        ImportantDateFormSection(
          label: 'Bordure de la case',
          child: ImportantDateColorPicker(
            colors: ImportantDatePalette.borderColors,
            selectedColor: viewModel.borderColor,
            onColorSelected: viewModel.setBorderColor,
          ),
        ),
        const SizedBox(height: 12),
        const ImportantDateFormSection(
          label: 'Aperçu dans le calendrier',
          child: Center(child: ImportantDatePreview()),
        ),
      ],
    );
  }

  // --- Enregistre, puis revient à l'écran d'où l'on vient ---
  Future<void> _handleSave(
    BuildContext context,
    AddEditImportantDateViewModel viewModel,
  ) async {
    final saved = await viewModel.save();
    if (!context.mounted) return;

    if (saved) {
      context.pop();
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    }
  }
}
