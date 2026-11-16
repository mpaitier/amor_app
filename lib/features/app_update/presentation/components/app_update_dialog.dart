// ============================================================================
// APP UPDATE DIALOG
// ============================================================================
// Fenêtre "Nouvelle version disponible". Le bouton principal télécharge le
// fichier de la plateforme (.apk ou .ipa) ; le lien secondaire ouvre la
// page de la release, avec les nouveautés. Composant "bête" : reçoit la
// mise à jour et ce qu'il faut faire des liens.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/app_update.dart';

enum AppUpdateChoice { later, download, details }

Future<AppUpdateChoice> showAppUpdateDialog(
  BuildContext context, {
  required AppUpdate update,
}) async {
  final choice = await showDialog<AppUpdateChoice>(
    context: context,
    builder: (dialogContext) => AppUpdateDialog(
      update: update,
      onChoice: (choice) => Navigator.of(dialogContext).pop(choice),
    ),
  );
  return choice ?? AppUpdateChoice.later;
}

class AppUpdateDialog extends StatelessWidget {
  final AppUpdate update;
  final ValueChanged<AppUpdateChoice> onChoice;

  const AppUpdateDialog({
    super.key,
    required this.update,
    required this.onChoice,
  });

  // --- Comment installer, selon la plateforme ---
  String get _installHint {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Installe le fichier .ipa avec AltStore (My Apps → +), '
          'par-dessus l\'app actuelle.';
    }
    return 'Ouvre le fichier .apk téléchargé pour l\'installer par-dessus '
        'l\'app actuelle.';
  }

  @override
  Widget build(BuildContext context) {
    final release = update.release;

    return AlertDialog(
      title: const Text('Nouvelle version disponible'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amor ${release.version} est sortie. '
            'Tu as la version ${update.installedVersion}.',
          ),
          const SizedBox(height: 12),
          Text('$_installHint Tes souvenirs et ta connexion sont conservés.'),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onChoice(AppUpdateChoice.details),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: amorDarkRose,
              ),
              child: const Text('Voir les nouveautés'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => onChoice(AppUpdateChoice.later),
          child: const Text('Plus tard'),
        ),
        FilledButton(
          onPressed: () => onChoice(AppUpdateChoice.download),
          style: FilledButton.styleFrom(backgroundColor: amorDarkRose),
          child: const Text('Télécharger'),
        ),
      ],
    );
  }
}
