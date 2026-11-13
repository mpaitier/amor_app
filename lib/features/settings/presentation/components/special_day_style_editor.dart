// ============================================================================
// SPECIAL DAY STYLE EDITOR
// ============================================================================
// Réglage de l'apparence d'un jour spécial : emoji (grille dépliable),
// bordure et fond. Reprend les composants du formulaire des dates
// importantes. Composant "bête" : reçoit le style et un callback.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../important_dates/presentation/components/important_date_color_row.dart';
import '../../../important_dates/presentation/components/important_date_emoji_button.dart';
import '../../../important_dates/presentation/components/important_date_emoji_picker.dart';
import '../../../important_dates/presentation/models/important_date_palette.dart';
import '../../domain/entities/special_day_style.dart';

class SpecialDayStyleEditor extends StatefulWidget {
  final SpecialDayStyle style;
  final ValueChanged<SpecialDayStyle> onChanged;

  const SpecialDayStyleEditor({
    super.key,
    required this.style,
    required this.onChanged,
  });

  @override
  State<SpecialDayStyleEditor> createState() => _SpecialDayStyleEditorState();
}

class _SpecialDayStyleEditorState extends State<SpecialDayStyleEditor> {
  // --- Pur état d'interface : la grille d'emojis est-elle dépliée ? ---
  bool _isEmojiPickerOpen = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ImportantDateEmojiButton(
              emoji: style.emoji,
              isOpen: _isEmojiPickerOpen,
              onTap: () {
                setState(() => _isEmojiPickerOpen = !_isEmojiPickerOpen);
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'Emoji',
              style: TextStyle(
                color: amorDarkRose,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _isEmojiPickerOpen
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ImportantDateEmojiPicker(
                    selectedEmoji: style.emoji,
                    onEmojiSelected: (emoji) {
                      widget.onChanged(style.copyWith(emoji: emoji));
                      setState(() => _isEmojiPickerOpen = false);
                    },
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 12),
        ImportantDateColorRow(
          label: 'Bordure',
          colors: ImportantDatePalette.borderColors,
          selectedColor: style.borderColor,
          onColorSelected: (color) {
            widget.onChanged(style.copyWith(borderColor: color));
          },
        ),
        const SizedBox(height: 12),
        ImportantDateColorRow(
          label: 'Fond',
          colors: ImportantDatePalette.backgroundColors,
          selectedColor: style.backgroundColor,
          onColorSelected: (color) {
            widget.onChanged(style.copyWith(backgroundColor: color));
          },
        ),
      ],
    );
  }
}
