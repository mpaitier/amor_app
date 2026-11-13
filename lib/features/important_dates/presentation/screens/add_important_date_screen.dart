// ============================================================================
// ADD / EDIT IMPORTANT DATE SCREEN
// ============================================================================
// Formulaire d'une date importante. De haut en bas : l'aperçu, le titre,
// l'emoji et le jour, la répétition, la bordure, le fond, puis les boutons
// annuler et valider fixés en bas.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../color_history/domain/entities/color_history_kind.dart';
import '../../../color_history/presentation/viewmodels/recent_colors_viewmodel.dart';
import '../../domain/entities/important_date_entity.dart';
import '../components/important_date_color_row.dart';
import '../components/important_date_emoji_date_row.dart';
import '../components/important_date_form_actions.dart';
import '../components/important_date_preview.dart';
import '../components/important_date_recurrence_field.dart';
import '../components/important_date_title_field.dart';
import '../models/important_date_palette.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';

class AddImportantDateScreen extends StatelessWidget {
  final ImportantDateEntity? dateToEdit;

  const AddImportantDateScreen({super.key, this.dateToEdit});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AddEditImportantDateViewModel(
            addImportantDate: sl.addImportantDate,
            updateImportantDate: sl.updateImportantDate,
            dateToEdit: dateToEdit,
          ),
        ),
        // --- Couleurs libres récentes, lues par les rangées de couleurs ---
        ChangeNotifierProvider(
          create: (_) => RecentColorsViewModel(
            getRecentColors: sl.getRecentColors,
            addRecentColor: sl.addRecentColor,
            removeRecentColor: sl.removeRecentColor,
          ),
        ),
      ],
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
      bottomNavigationBar: ImportantDateFormActions(
        isSaving: viewModel.isSaving,
        onCancel: () => context.pop(),
        onSubmit: () => _handleSave(context, viewModel),
      ),
    );
  }

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
    );
  }

  // --- Formulaire défilant ---
  Widget _buildForm(AddEditImportantDateViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const ImportantDatePreview(),
        const SizedBox(height: 16),
        const ImportantDateTitleField(),
        const SizedBox(height: 12),
        const ImportantDateEmojiDateRow(),
        const SizedBox(height: 12),
        const ImportantDateRecurrenceField(),
        const SizedBox(height: 16),
        ImportantDateColorRow(
          label: 'Bordure',
          colors: ImportantDatePalette.borderColors,
          historyKind: ColorHistoryKind.border,
          selectedColor: viewModel.borderColor,
          onColorSelected: viewModel.setBorderColor,
        ),
        const SizedBox(height: 12),
        ImportantDateColorRow(
          label: 'Fond',
          colors: ImportantDatePalette.backgroundColors,
          historyKind: ColorHistoryKind.background,
          selectedColor: viewModel.backgroundColor,
          onColorSelected: viewModel.setBackgroundColor,
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
