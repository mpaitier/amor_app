// ============================================================================
// EVENT DETAIL OPTIONS MENU
// ============================================================================
// Dropdown with Edit / Delete actions, anchored below the "more" icon.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EventDetailOptionsMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventDetailOptionsMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 0,
      child: Material(
        color: amorCream,
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOption(
              label: 'Modifier',
              icon: Icons.edit,
              color: Colors.black,
              iconColor: amorDarkRose,
              onTap: onEdit,
            ),
            _buildOption(
              label: 'Supprimer',
              icon: Icons.delete,
              color: Colors.red,
              iconColor: Colors.red,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}