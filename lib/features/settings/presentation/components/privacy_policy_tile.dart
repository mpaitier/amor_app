// ============================================================================
// PRIVACY POLICY TILE
// ============================================================================
// Ligne "Politique de confidentialité" : ouvre la page web dans le
// navigateur. Google Play demande que l'app y donne accès.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_links.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyTile extends StatelessWidget {
  const PrivacyPolicyTile({super.key});

  Future<void> _open(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
    if (opened || !context.mounted) return;

    // --- Aucun navigateur : on donne au moins l'adresse ---
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouvre $privacyPolicyUrl dans un navigateur')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.privacy_tip_outlined, color: amorDarkRose),
      title: const Text('Politique de confidentialité'),
      subtitle: const Text('Données enregistrées, conservation, tes droits'),
      trailing: const Icon(Icons.open_in_new, size: 20, color: amorDarkRose),
      onTap: () => _open(context),
    );
  }
}
