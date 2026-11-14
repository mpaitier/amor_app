// ============================================================================
// ACCOUNT CARD
// ============================================================================
// Bloc "Compte" des paramètres : l'adresse connectée et la déconnexion.
// Lit l'AuthSessionViewModel global.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/auth_session_viewmodel.dart';
import 'sign_out_dialog.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final session = context.read<AuthSessionViewModel>();
    final confirmed = await showSignOutDialog(context);
    if (confirmed) await session.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthSessionViewModel>().user;
    final email = user?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.account_circle, color: amorDarkRose),
          title: const Text('Connecté avec'),
          subtitle: Text(email.isEmpty ? 'Compte sans adresse e-mail' : email),
        ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context),
          icon: const Icon(Icons.logout),
          label: const Text('Se déconnecter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: amorDarkRose,
            side: const BorderSide(color: amorDarkRose),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}
