// ============================================================================
// IMPORTANT DATE EMOJI PICKER
// ============================================================================
// Grille des emojis proposés, dépliée sous la case d'emoji. Celui qui est
// retenu est entouré. Le dernier bouton ouvre le clavier pour choisir
// n'importe quel autre emoji ; s'il n'est pas dans la liste, il s'affiche
// en tête de grille. Composant "bête" : ne connaît pas le ViewModel.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/important_date_palette.dart';
import 'custom_emoji_dialog.dart';

class ImportantDateEmojiPicker extends StatelessWidget {
  final String selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  const ImportantDateEmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = !ImportantDatePalette.emojis.contains(selectedEmoji);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: outlineLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              if (isCustom) _buildChoice(selectedEmoji),
              for (final emoji in ImportantDatePalette.emojis)
                _buildChoice(emoji),
              _buildMoreButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoice(String emoji) {
    final isSelected = emoji == selectedEmoji;

    return InkWell(
      onTap: () => onEmojiSelected(emoji),
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? amorDarkRose : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22, height: 1.0)),
      ),
    );
  }

  // --- Ouvre le clavier pour un emoji hors de la liste ---
  Widget _buildMoreButton(BuildContext context) {
    return Tooltip(
      message: 'Un autre emoji',
      child: InkWell(
        onTap: () => _pickCustomEmoji(context),
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: outlineVariantLight),
          ),
          child: const Icon(Icons.add_reaction_outlined, color: amorDarkRose),
        ),
      ),
    );
  }

  Future<void> _pickCustomEmoji(BuildContext context) async {
    final emoji = await showDialog<String>(
      context: context,
      builder: (_) => const CustomEmojiDialog(),
    );
    if (emoji != null) onEmojiSelected(emoji);
  }
}
