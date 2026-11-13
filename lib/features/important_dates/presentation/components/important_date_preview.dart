// ============================================================================
// IMPORTANT DATE PREVIEW
// ============================================================================
// Aperçu en haut du formulaire : le bandeau de la date, mis à jour à chaque
// frappe dans le titre et à chaque choix d'emoji, de jour ou de couleur.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/important_date_labels.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';
import 'important_date_banner.dart';

class ImportantDatePreview extends StatelessWidget {
  const ImportantDatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();

    // --- Le titre vit dans un contrôleur de texte : on l'écoute à part
    // --- pour suivre la saisie lettre par lettre ---
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: viewModel.titleController,
      builder: (context, value, _) {
        final draft = viewModel.draft;

        return ImportantDateBanner(
          emoji: draft.emoji,
          title: draft.title.isEmpty ? 'Titre' : draft.title,
          countdown: formatShortCountdown(
            draft.nextOccurrence(viewModel.today),
            viewModel.today,
          ),
          backgroundColor: draft.backgroundColor,
          borderColor: draft.borderColor,
        );
      },
    );
  }
}
