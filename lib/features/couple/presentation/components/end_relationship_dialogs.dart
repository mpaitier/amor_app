// ============================================================================
// END RELATIONSHIP DIALOGS
// ============================================================================
// Confirmations autour de l'arrêt de la relation. Chaque fonction renvoie
// le choix de la personne ; fermer la fenêtre revient à ne rien faire.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum EndRequestChoice { accept, decline, later }

// --- Fenêtre commune : titre, texte, bouton d'annulation et bouton
// --- d'action ---
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmLabel,
  bool isDestructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? errorLight : amorDarkRose,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<bool> showRequestEndDialog(BuildContext context) {
  return _confirm(
    context,
    title: 'Arrêter la relation ?',
    content: 'Les autres membres seront prévenus. La relation ne sera '
        'supprimée que lorsque tout le monde aura accepté : tous les '
        'souvenirs, dates, photos et réglages seront alors effacés '
        'définitivement.\n\nTu pourras annuler ta demande tant qu\'elle est '
        'en cours.',
    confirmLabel: 'Envoyer la demande',
  );
}

Future<bool> showAcceptEndDialog(BuildContext context) {
  return _confirm(
    context,
    title: 'Accepter l\'arrêt de la relation ?',
    content: 'Quand tous les membres auront accepté, la relation sera '
        'supprimée avec tous ses souvenirs, dates et photos. C\'est '
        'définitif.',
    confirmLabel: 'J\'accepte',
  );
}

Future<bool> showCancelEndDialog(BuildContext context) {
  return _confirm(
    context,
    title: 'Annuler ta demande ?',
    content: 'La relation continue comme avant. Les réponses déjà données '
        'sont oubliées.',
    confirmLabel: 'Annuler la demande',
    isDestructive: false,
  );
}

// --- Fenêtre affichée à l'ouverture de l'app quand une demande attend la
// --- réponse de la personne ---
Future<EndRequestChoice> showEndRequestPromptDialog(
  BuildContext context, {
  required String requesterName,
}) async {
  final choice = await showDialog<EndRequestChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Demande d\'arrêt de la relation'),
      content: Text(
        '$requesterName souhaite arrêter votre relation sur Amor. Si tout le '
        'monde accepte, tous vos souvenirs, dates et photos seront supprimés.'
        '\n\nTu pourras changer d\'avis plus tard dans les paramètres.',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(EndRequestChoice.later),
          child: const Text('Plus tard'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(EndRequestChoice.decline),
          style: TextButton.styleFrom(foregroundColor: amorDarkRose),
          child: const Text('Refuser'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(EndRequestChoice.accept),
          style: TextButton.styleFrom(foregroundColor: errorLight),
          child: const Text('Accepter'),
        ),
      ],
    ),
  );
  return choice ?? EndRequestChoice.later;
}
