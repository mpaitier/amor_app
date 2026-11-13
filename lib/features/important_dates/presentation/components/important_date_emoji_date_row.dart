// ============================================================================
// IMPORTANT DATE EMOJI + DATE ROW
// ============================================================================
// La case d'emoji et le jour, côte à côte. Un tap sur l'emoji déplie la
// grille de choix juste en dessous ; un tap sur le jour ouvre le sélecteur
// de date, qui accepte les jours à venir.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';
import 'important_date_date_field.dart';
import 'important_date_emoji_button.dart';
import 'important_date_emoji_picker.dart';

class ImportantDateEmojiDateRow extends StatefulWidget {
  const ImportantDateEmojiDateRow({super.key});

  @override
  State<ImportantDateEmojiDateRow> createState() =>
      _ImportantDateEmojiDateRowState();
}

class _ImportantDateEmojiDateRowState extends State<ImportantDateEmojiDateRow> {
  // --- Bornes du sélecteur de date, en années autour d'aujourd'hui ---
  static const int _yearsBack = 100;
  static const int _yearsAhead = 20;

  // --- Pur état d'interface : la grille d'emojis est-elle dépliée ? ---
  bool _isEmojiPickerOpen = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ImportantDateEmojiButton(
              emoji: viewModel.selectedEmoji,
              isOpen: _isEmojiPickerOpen,
              onTap: () {
                setState(() => _isEmojiPickerOpen = !_isEmojiPickerOpen);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ImportantDateDateField(
                date: viewModel.selectedDate,
                onTap: () => _pickDate(viewModel),
              ),
            ),
          ],
        ),

        // --- Grille d'emojis, dépliée sous la ligne ---
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _isEmojiPickerOpen
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ImportantDateEmojiPicker(
                    selectedEmoji: viewModel.selectedEmoji,
                    onEmojiSelected: (emoji) {
                      viewModel.setEmoji(emoji);
                      setState(() => _isEmojiPickerOpen = false);
                    },
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Future<void> _pickDate(AddEditImportantDateViewModel viewModel) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(now.year - _yearsBack),
      lastDate: DateTime(now.year + _yearsAhead, 12, 31),
    );
    if (picked != null) viewModel.setDate(picked);
  }
}
