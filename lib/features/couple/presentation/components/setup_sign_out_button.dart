// ============================================================================
// SETUP SIGN OUT BUTTON
// ============================================================================
// Lien sous la carte de création de relation, pour changer de compte si
// on s'est connecté avec le mauvais.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cream_label.dart';
import '../viewmodels/couple_session_viewmodel.dart';

class SetupSignOutButton extends StatelessWidget {
  const SetupSignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<CoupleSessionViewModel>();
    final email = session.user?.email ?? '';

    return Column(
      children: [
        if (email.isNotEmpty)
          CreamLabel(
            text: 'Connecté avec $email',
            style: const TextStyle(color: amorDarkRose, fontSize: 13),
          ),
        TextButton(
          onPressed: session.signOut,
          style: TextButton.styleFrom(foregroundColor: amorDarkRose),
          child: const CreamLabel(
            text: 'Utiliser un autre compte',
            style: TextStyle(
              color: amorDarkRose,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
