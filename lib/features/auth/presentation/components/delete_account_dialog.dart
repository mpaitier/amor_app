// ============================================================================
// DELETE ACCOUNT DIALOG
// ============================================================================
// Confirmation avant la suppression définitive du compte. Renvoie true si
// la personne confirme.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Supprimer ton compte ?'),
      content: const Text(
        'Ton compte, ton profil et les réglages de ton téléphone seront '
        'effacés.\n\nLes souvenirs que tu as créés restent visibles pour les '
        'autres membres de la relation, signés « ancien membre ». Si tu es '
        'seul dans la relation, elle sera supprimée avec tous ses souvenirs '
        'et ses photos.\n\nC\'est définitif.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: errorLight),
          child: const Text('Supprimer mon compte'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
