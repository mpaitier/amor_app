// ============================================================================
// DELETE IMPORTANT DATE CONFIRMATION DIALOG
// ============================================================================
// Se ferme en renvoyant true si la suppression est confirmée.

import 'package:flutter/material.dart';

class DeleteImportantDateDialog extends StatelessWidget {
  final String dateTitle;

  const DeleteImportantDateDialog({super.key, required this.dateTitle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer cette date ?'),
      content: Text(
        'Es-tu sûr(e) de vouloir supprimer "$dateTitle" ? Cette action est définitive.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
