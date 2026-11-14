// ============================================================================
// END RELATIONSHIP CARD
// ============================================================================
// Bloc "Arrêter la relation" des paramètres. Sans demande : un bouton pour
// en faire une. Avec une demande : qui l'a faite, combien de membres ont
// accepté (x/total), et selon la personne, accepter ou annuler.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/couple_end_viewmodel.dart';
import '../viewmodels/couple_session_viewmodel.dart';
import 'end_relationship_dialogs.dart';

class EndRelationshipCard extends StatelessWidget {
  const EndRelationshipCard({super.key});

  Future<void> _request(BuildContext context) async {
    final viewModel = context.read<CoupleEndViewModel>();
    if (await showRequestEndDialog(context)) await viewModel.requestEnd();
  }

  Future<void> _accept(BuildContext context) async {
    final viewModel = context.read<CoupleEndViewModel>();
    if (await showAcceptEndDialog(context)) await viewModel.accept();
  }

  Future<void> _cancel(BuildContext context) async {
    final viewModel = context.read<CoupleEndViewModel>();
    if (await showCancelEndDialog(context)) await viewModel.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<CoupleSessionViewModel>();
    final viewModel = context.watch<CoupleEndViewModel>();
    final couple = session.couple;
    final myUid = session.user?.uid;
    if (couple == null || myUid == null) return const SizedBox.shrink();

    final request = couple.endRequest;
    final children = <Widget>[];

    if (request == null) {
      children.addAll([
        const Text(
          'Si vous décidez d\'arrêter, tous les membres doivent l\'accepter. '
          'La relation est alors supprimée avec tous ses souvenirs.',
          style: TextStyle(color: onSurfaceVariantLight),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'Demander l\'arrêt de la relation',
          icon: Icons.heart_broken_outlined,
          isBusy: viewModel.isBusy,
          onPressed: () => _request(context),
        ),
      ]);
    } else {
      final isRequester = request.isRequestedBy(myUid);
      final requesterName =
          couple.memberById(request.requestedBy)?.nickname ?? 'Un ancien membre';

      children.addAll([
        Text(
          isRequester
              ? 'Tu as demandé l\'arrêt de la relation.'
              : '$requesterName a demandé l\'arrêt de la relation.',
          style: const TextStyle(fontSize: 16, color: onSurfaceLight),
        ),
        const SizedBox(height: 6),
        Text(
          '${couple.endAcceptedCount}/${couple.members.length} membres ont '
          'accepté',
          style: const TextStyle(
            color: amorDarkRose,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (!request.hasAccepted(myUid))
          _ActionButton(
            label: 'Accepter l\'arrêt',
            icon: Icons.check,
            isBusy: viewModel.isBusy,
            onPressed: () => _accept(context),
          )
        else if (!isRequester)
          const Text(
            'Tu as accepté. La relation sera supprimée quand tout le monde '
            'aura accepté.',
            style: TextStyle(color: onSurfaceVariantLight),
          ),
        if (isRequester)
          TextButton(
            onPressed: viewModel.isBusy ? null : () => _cancel(context),
            style: TextButton.styleFrom(foregroundColor: amorDarkRose),
            child: const Text('Annuler ma demande'),
          ),
      ]);
    }

    if (viewModel.errorMessage != null) {
      children.addAll([
        const SizedBox(height: 8),
        Text(
          viewModel.errorMessage!,
          style: const TextStyle(color: errorLight),
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

// --- Bouton rouge des actions définitives ---
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isBusy;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isBusy ? null : onPressed,
      icon: isBusy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: errorLight,
        side: const BorderSide(color: errorLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
