// ============================================================================
// IMPORTANT DATE TILE
// ============================================================================
// Carré d'une date importante : son emoji sur le fond et la bordure choisis.
// Utilisé par la case du calendrier et par l'aperçu du formulaire.

import 'package:flutter/material.dart';

class ImportantDateTile extends StatelessWidget {
  final String emoji;
  final int backgroundColor;
  final int borderColor;
  final double emojiSize;

  const ImportantDateTile({
    super.key,
    required this.emoji,
    required this.backgroundColor,
    required this.borderColor,
    this.emojiSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(backgroundColor),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(borderColor), width: 2),
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: emojiSize, height: 1.0),
      ),
    );
  }
}
