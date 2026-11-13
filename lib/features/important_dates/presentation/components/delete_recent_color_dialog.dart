// ============================================================================
// DELETE RECENT COLOR DIALOG
// ============================================================================
// Confirmation avant de retirer une couleur des récentes. Se ferme en
// renvoyant true si l'on confirme.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DeleteRecentColorDialog extends StatelessWidget {
  final int color;

  const DeleteRecentColorDialog({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Retirer cette couleur ?'),
      content: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(color),
              border: Border.all(color: outlineVariantLight),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Elle ne sera plus proposée dans les couleurs récentes.'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Retirer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
