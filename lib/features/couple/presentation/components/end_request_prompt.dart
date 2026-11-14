// ============================================================================
// END REQUEST PROMPT
// ============================================================================
// Posé sur l'écran principal, sans rien afficher lui-même. Quand une
// demande d'arrêt attend la réponse de la personne, ouvre une fenêtre pour
// accepter (avec confirmation), refuser ou répondre plus tard. "Plus tard"
// repose la question au prochain lancement ; un refus ne la repose plus,
// mais on peut accepter ensuite depuis les paramètres.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../viewmodels/couple_end_viewmodel.dart';
import '../viewmodels/couple_session_viewmodel.dart';
import 'end_relationship_dialogs.dart';

class EndRequestPrompt extends StatelessWidget {
  const EndRequestPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoupleEndViewModel(
        requestCoupleEnd: sl.requestCoupleEnd,
        respondToCoupleEnd: sl.respondToCoupleEnd,
        cancelCoupleEnd: sl.cancelCoupleEnd,
      ),
      child: const _EndRequestPromptListener(),
    );
  }
}

class _EndRequestPromptListener extends StatefulWidget {
  const _EndRequestPromptListener();

  @override
  State<_EndRequestPromptListener> createState() =>
      _EndRequestPromptListenerState();
}

class _EndRequestPromptListenerState extends State<_EndRequestPromptListener> {
  // --- Demande déjà présentée pendant cette ouverture de l'app ---
  String? _promptedKey;

  Future<void> _showPrompt(String requesterName) async {
    final viewModel = context.read<CoupleEndViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final choice = await showEndRequestPromptDialog(
      context,
      requesterName: requesterName,
    );
    if (!mounted) return;

    var succeeded = true;
    switch (choice) {
      case EndRequestChoice.accept:
        if (await showAcceptEndDialog(context)) {
          succeeded = await viewModel.accept();
        }
      case EndRequestChoice.decline:
        succeeded = await viewModel.decline();
      case EndRequestChoice.later:
        break;
    }

    final error = viewModel.errorMessage;
    if (!succeeded && error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<CoupleSessionViewModel>();
    final couple = session.couple;
    final uid = session.user?.uid;
    final request = couple?.endRequest;

    if (couple != null &&
        uid != null &&
        request != null &&
        couple.needsEndAnswerFrom(uid)) {
      final key = '${couple.id}/${request.requestedBy}/${request.requestedAt}';
      if (key != _promptedKey) {
        _promptedKey = key;
        final requesterName =
            couple.memberById(request.requestedBy)?.nickname ??
                'Un ancien membre';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showPrompt(requesterName);
        });
      }
    }

    return const SizedBox.shrink();
  }
}
