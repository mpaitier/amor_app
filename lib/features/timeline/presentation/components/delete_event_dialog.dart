// ============================================================================
// DELETE EVENT CONFIRMATION DIALOG
// ============================================================================

import 'package:flutter/material.dart';

class DeleteEventDialog extends StatelessWidget {
  final String eventTitle;
  final VoidCallback onConfirm;

  const DeleteEventDialog({
    super.key,
    required this.eventTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer ce souvenir ?'),
      content: Text(
        'Es-tu sûr(e) de vouloir supprimer "$eventTitle" ? Cette action est définitive.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}