// ============================================================================
// IMPORTANT DATE EMOJI PICKER
// ============================================================================
// Grille des emojis proposés. Celui qui est retenu est entouré.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/important_date_palette.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';

class ImportantDateEmojiPicker extends StatelessWidget {
  const ImportantDateEmojiPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final emoji in ImportantDatePalette.emojis)
          _buildChoice(
            emoji: emoji,
            isSelected: emoji == viewModel.selectedEmoji,
            onTap: () => viewModel.setEmoji(emoji),
          ),
      ],
    );
  }

  Widget _buildChoice({
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(
            color: isSelected ? amorDarkRose : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22, height: 1.0)),
      ),
    );
  }
}
