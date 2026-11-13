// ============================================================================
// IMPORTANT DATE PREVIEW
// ============================================================================
// Aperçu de la case telle qu'elle apparaîtra dans le calendrier, mis à jour
// à chaque choix d'emoji ou de couleur.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';
import 'important_date_tile.dart';

class ImportantDatePreview extends StatelessWidget {
  const ImportantDatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${viewModel.selectedDate.day}',
          style: const TextStyle(
            color: amorDarkRose,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 64,
          height: 64,
          child: ImportantDateTile(
            emoji: viewModel.selectedEmoji,
            backgroundColor: viewModel.backgroundColor,
            borderColor: viewModel.borderColor,
            emojiSize: 28,
          ),
        ),
      ],
    );
  }
}
