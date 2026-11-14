// ============================================================================
// AUTH DIVIDER
// ============================================================================
// Trait "ou" entre le formulaire e-mail et le bouton Google.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: outlineVariantLight)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: TextStyle(color: outlineLight)),
        ),
        Expanded(child: Divider(color: outlineVariantLight)),
      ],
    );
  }
}
