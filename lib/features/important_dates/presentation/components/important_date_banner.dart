// ============================================================================
// IMPORTANT DATE BANNER
// ============================================================================
// Bandeau d'une date importante : emoji, titre et jours restants, sur le
// fond et la bordure choisis. Composant "bête" : reçoit tout en paramètre.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ImportantDateBanner extends StatelessWidget {
  final String emoji;
  final String title;
  final String countdown;
  final int backgroundColor;
  final int borderColor;

  const ImportantDateBanner({
    super.key,
    required this.emoji,
    required this.title,
    required this.countdown,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // --- Material transparent : sur un écran sans Scaffold (le journal),
    // --- les textes prendraient sinon le style de secours de Flutter,
    // --- souligné en jaune ---
    return Material(
      type: MaterialType.transparency,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Color(backgroundColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(borderColor), width: 2),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24, height: 1.0)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: onBackgroundLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            countdown,
            style: TextStyle(
              color: Color(borderColor),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
