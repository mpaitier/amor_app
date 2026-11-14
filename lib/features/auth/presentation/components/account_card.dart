// ============================================================================
// ACCOUNT CARD
// ============================================================================
// Bloc "Compte" des paramètres : l'adresse connectée, la déconnexion (qui ne
// fait pas quitter la relation), la règle de suppression après un an
// d'inactivité et la suppression du compte. Lit l'AuthSessionViewModel
// global et l'AccountViewModel fourni par l'écran des paramètres.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/account_viewmodel.dart';
import '../viewmodels/auth_session_viewmodel.dart';
import 'delete_account_dialog.dart';
import 'sign_out_dialog.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final session = context.read<AuthSessionViewModel>();
    final confirmed = await showSignOutDialog(context);
    if (confirmed) await session.signOut();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final viewModel = context.read<AccountViewModel>();
    final confirmed = await showDeleteAccountDialog(context);
    if (confirmed) await viewModel.deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthSessionViewModel>().user;
    final account = context.watch<AccountViewModel>();
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
          onPressed: account.isDeleting ? null : () => _confirmSignOut(context),
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
        const SizedBox(height: 16),
        const _InactivityNotice(),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: account.isDeleting ? null : () => _confirmDelete(context),
          icon: account.isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_forever_outlined),
          label: const Text('Supprimer mon compte'),
          style: TextButton.styleFrom(foregroundColor: errorLight),
        ),
        if (account.errorMessage != null)
          Text(
            account.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: errorLight),
          ),
      ],
    );
  }
}

// --- Règle de suppression automatique, affichée près de la déconnexion ---
class _InactivityNotice extends StatelessWidget {
  const _InactivityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: amorCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.hourglass_bottom, color: amorDarkRose, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Se déconnecter ne fait pas quitter la relation. Par contre, sans '
              'nouveau souvenir ni nouvelle date pendant un an, la relation et '
              'les comptes de ses membres sont supprimés. Vous serez prévenus '
              '30 jours puis 7 jours avant.',
              style: TextStyle(color: onSurfaceVariantLight, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
