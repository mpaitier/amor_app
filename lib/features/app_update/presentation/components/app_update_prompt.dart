// ============================================================================
// APP UPDATE PROMPT
// ============================================================================
// Posé sur l'écran principal, sans rien afficher lui-même. Dès que la
// vérification du lancement trouve une version plus récente, ouvre la
// fenêtre de mise à jour, une seule fois par lancement. Les liens
// s'ouvrent dans le navigateur, qui gère le téléchargement.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/app_update.dart';
import '../viewmodels/app_update_viewmodel.dart';
import 'app_update_dialog.dart';

class AppUpdatePrompt extends StatefulWidget {
  const AppUpdatePrompt({super.key});

  @override
  State<AppUpdatePrompt> createState() => _AppUpdatePromptState();
}

class _AppUpdatePromptState extends State<AppUpdatePrompt> {
  Future<void> _showPrompt(AppUpdate update) async {
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showAppUpdateDialog(context, update: update);

    final url = switch (choice) {
      AppUpdateChoice.download => update.release.downloadUrl,
      AppUpdateChoice.details => update.release.pageUrl,
      AppUpdateChoice.later => null,
    };
    if (url == null) return;

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text('Ouvre $url dans un navigateur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppUpdateViewModel>();
    final update = viewModel.pendingUpdate;

    if (update != null) {
      // --- Marqué tout de suite : un nouveau build ne doit pas ouvrir une
      // --- deuxième fenêtre ---
      viewModel.markPrompted();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showPrompt(update);
      });
    }

    return const SizedBox.shrink();
  }
}
