// ============================================================================
// MEMBER NAME TEXT
// ============================================================================
// "Créé par Lulu" : un début de phrase en gris, puis le surnom en gras dans
// la couleur du membre. Composant "bête" : reçoit ce qu'il affiche.

import 'package:flutter/material.dart';
import '../models/member_display.dart';

class MemberNameText extends StatelessWidget {
  final MemberDisplay display;
  final String prefix;
  final double fontSize;
  final int? maxLines;

  const MemberNameText({
    super.key,
    required this.display,
    this.prefix = '',
    this.fontSize = 16,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (prefix.isNotEmpty) TextSpan(text: prefix),
          TextSpan(
            text: display.name,
            style: TextStyle(
              color: display.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.5,
        color: const Color(0xFF616161),
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
    );
  }
}
