// ============================================================================
// SIGN OUT DIALOG
// ============================================================================
// Confirmation avant de se déconnecter. Renvoie true si la personne
// confirme.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

Future<bool> showSignOutDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Se déconnecter ?'),
      content: const Text(
        'Tu restes dans ta relation : tes souvenirs t\'attendront à ta '
        'prochaine connexion.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: amorDarkRose),
          child: const Text('Se déconnecter'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
