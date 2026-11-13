// ============================================================================
// CUSTOM EMOJI DIALOG
// ============================================================================
// Ouvre le clavier pour choisir n'importe quel emoji. Le champ ne garde que
// le dernier emoji touché, pour rattraper un mauvais choix ; la boîte ne
// se ferme qu'à la validation, en le renvoyant.

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

  // --- Pur état d'interface : l'emoji retenu pour l'instant ---
  String? _emoji;
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    final emoji = extractLastEmoji(text);

    // --- Le champ ne montre que l'emoji retenu ---
    final shown = emoji ?? '';
    if (_controller.text != shown) {
      _controller.value = TextEditingValue(
        text: shown,
        selection: TextSelection.collapsed(offset: shown.length),
      );
    }

    setState(() {
      _emoji = emoji;
      _showError = emoji == null && text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _emoji;

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
            style: const TextStyle(fontSize: 40),
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: '😊',
              hintStyle: const TextStyle(color: outlineVariantLight),
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
        TextButton(
          onPressed: emoji == null ? null : () => Navigator.of(context).pop(emoji),
          child: Text(
            'Valider',
            style: TextStyle(
              color: emoji == null ? outlineLight : amorDarkRose,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
