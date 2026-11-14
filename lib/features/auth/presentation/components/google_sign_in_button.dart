// ============================================================================
// GOOGLE SIGN IN BUTTON
// ============================================================================
// Bouton secondaire "Continuer avec Google". Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: isBusy ? null : onPressed,
        icon: const Icon(Icons.account_circle_outlined),
        label: const Text(
          'Continuer avec Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: amorDarkRose,
          backgroundColor: Colors.white,
          side: const BorderSide(color: outlineLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
