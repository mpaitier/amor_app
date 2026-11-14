// ============================================================================
// FORGOT PASSWORD BUTTON
// ============================================================================
// Petit lien sous le mot de passe, visible en mode connexion seulement.
// Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ForgotPasswordButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onPressed;

  const ForgotPasswordButton({
    super.key,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: isBusy ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: amorDarkRose,
          textStyle: const TextStyle(fontSize: 13),
        ),
        child: const Text('Mot de passe oublié ?'),
      ),
    );
  }
}
