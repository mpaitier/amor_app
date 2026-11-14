// ============================================================================
// AUTH MODE SWITCH
// ============================================================================
// Lien texte qui bascule entre connexion et création de compte.
// Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthModeSwitch extends StatelessWidget {
  final bool isRegistering;
  final bool isBusy;
  final VoidCallback onToggle;

  const AuthModeSwitch({
    super.key,
    required this.isRegistering,
    required this.isBusy,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isBusy ? null : onToggle,
      style: TextButton.styleFrom(foregroundColor: amorDarkRose),
      child: Text(
        isRegistering
            ? 'Déjà un compte ? Se connecter'
            : 'Pas encore de compte ? En créer un',
        textAlign: TextAlign.center,
      ),
    );
  }
}
