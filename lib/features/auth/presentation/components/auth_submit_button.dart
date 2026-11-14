// ============================================================================
// AUTH SUBMIT BUTTON
// ============================================================================
// Bouton principal du formulaire e-mail. Affiche un indicateur pendant
// l'appel. Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool isBusy;
  final VoidCallback onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: amorDarkRose,
          foregroundColor: Colors.white,
          disabledBackgroundColor: amorDarkRose.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: isBusy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
