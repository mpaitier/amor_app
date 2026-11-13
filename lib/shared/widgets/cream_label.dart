// ============================================================================
// CREAM LABEL
// ============================================================================
// Pastille crème derrière un texte posé directement sur le fond à cœurs,
// pour qu'il reste lisible. Composant "bête" : reçoit le texte et son style.

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CreamLabel extends StatelessWidget {
  final String text;
  final TextStyle style;

  const CreamLabel({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: amorCreamTransparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}
