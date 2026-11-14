// ============================================================================
// INVITE CODE INPUT
// ============================================================================
// Champ du code d'invitation : majuscules, chiffres en police à chasse
// fixe, pour que le code se lise comme il s'écrit.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/utils/invite_code.dart';

class InviteCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const InviteCodeInput({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      autocorrect: false,
      enableSuggestions: false,
      // --- Marge pour un tiret ou des espaces collés avec le code ---
      maxLength: inviteCodeLength + 4,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 22,
        letterSpacing: 4,
        fontWeight: FontWeight.bold,
        color: amorDarkRose,
      ),
      decoration: InputDecoration(
        labelText: 'Code d\'invitation',
        counterText: '',
        prefixIcon: const Icon(Icons.vpn_key_outlined, color: amorDarkRose),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineLight),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariantLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: amorDarkRose, width: 2),
        ),
      ),
    );
  }
}
