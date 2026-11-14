// ============================================================================
// AUTH TEXT FIELD
// ============================================================================
// Champ du formulaire de connexion, habillé comme ceux des paramètres. En
// mode mot de passe, un œil permet d'afficher ce qui est tapé.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: widget.isPassword && _isObscured,
      autocorrect: !widget.isPassword,
      enableSuggestions: !widget.isPassword,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: amorDarkRose),
        suffixIcon: widget.isPassword ? _buildVisibilityToggle() : null,
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

  Widget _buildVisibilityToggle() {
    return IconButton(
      tooltip: _isObscured ? 'Afficher' : 'Masquer',
      icon: Icon(
        _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: outlineLight,
      ),
      onPressed: () => setState(() => _isObscured = !_isObscured),
    );
  }
}
