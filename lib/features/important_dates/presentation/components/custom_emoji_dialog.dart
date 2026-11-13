// ============================================================================
// CUSTOM EMOJI DIALOG
// ============================================================================
// Ouvre le clavier pour choisir n'importe quel emoji. Dès qu'un emoji est
// tapé, la boîte se ferme en le renvoyant.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/emoji_input.dart';

class CustomEmojiDialog extends StatefulWidget {
  const CustomEmojiDialog({super.key});

  @override
  State<CustomEmojiDialog> createState() => _CustomEmojiDialogState();
}

class _CustomEmojiDialogState extends State<CustomEmojiDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    final emoji = extractEmoji(text);
    if (emoji != null) {
      Navigator.of(context).pop(emoji);
      return;
    }
    setState(() => _showError = text.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Un autre emoji'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ouvre les emojis de ton clavier et touches-en un.',
            style: TextStyle(color: outlineLight),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32),
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: '😊',
              errorText: _showError ? 'Ce n\'est pas un emoji' : null,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: amorDarkRose, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
