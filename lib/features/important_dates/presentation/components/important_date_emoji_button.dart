// ============================================================================
// IMPORTANT DATE EMOJI BUTTON
// ============================================================================
// Case carrée qui affiche l'emoji retenu. Un tap déplie ou replie la grille
// de choix. Composant "bête" : ne connaît pas le ViewModel.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ImportantDateEmojiButton extends StatelessWidget {
  final String emoji;
  final bool isOpen;
  final VoidCallback onTap;

  const ImportantDateEmojiButton({
    super.key,
    required this.emoji,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: amorDarkRose, width: isOpen ? 2 : 1),
    );

    return Semantics(
      button: true,
      label: 'Choisir un emoji',
      child: Material(
        color: Colors.white,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24, height: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
