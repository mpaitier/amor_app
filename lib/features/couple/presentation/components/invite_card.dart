// ============================================================================
// INVITE CARD
// ============================================================================
// Code d'invitation en grand, avec de quoi copier le code ou le lien.
// Composant "bête" : reçoit le code et construit le lien lui-même.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/utils/invite_code.dart';

class InviteCard extends StatelessWidget {
  final String inviteCode;

  const InviteCard({super.key, required this.inviteCode});

  Future<void> _copy(BuildContext context, String text, String message) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pour inviter quelqu\'un, envoie-lui le lien ou le code :',
          style: TextStyle(color: onSurfaceVariantLight),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: amorCream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              inviteCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 28,
                letterSpacing: 6,
                fontWeight: FontWeight.bold,
                color: amorDarkRose,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _copy(
                context,
                inviteLinkFor(inviteCode),
                'Lien copié',
              ),
              icon: const Icon(Icons.link),
              label: const Text('Copier le lien'),
              style: _buttonStyle,
            ),
            OutlinedButton.icon(
              onPressed: () => _copy(context, inviteCode, 'Code copié'),
              icon: const Icon(Icons.copy),
              label: const Text('Copier le code'),
              style: _buttonStyle,
            ),
          ],
        ),
      ],
    );
  }

  static final ButtonStyle _buttonStyle = OutlinedButton.styleFrom(
    foregroundColor: amorDarkRose,
    side: const BorderSide(color: amorDarkRose),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  );
}
