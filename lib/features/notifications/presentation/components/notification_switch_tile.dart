// ============================================================================
// NOTIFICATION SWITCH TILE
// ============================================================================
// Une ligne avec un interrupteur. Grisée et inerte quand onChanged est nul
// (interrupteur général coupé). Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  // --- Retrait à gauche pour les réglages qui dépendent d'un autre ---
  final double indent;

  const NotificationSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isEnabled ? onBackgroundLight : outlineLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(color: outlineLight, fontSize: 13),
                  ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
