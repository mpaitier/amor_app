// ============================================================================
// AUTH HEADER
// ============================================================================
// Icône de l'app et nom, en haut de l'écran de connexion.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cream_label.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/amorapp.png',
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        const CreamLabel(
          text: 'Amor',
          style: TextStyle(
            color: amorDarkRose,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const CreamLabel(
          text: 'Votre histoire, rien qu\'à vous',
          style: TextStyle(color: amorDarkRose, fontSize: 15),
        ),
      ],
    );
  }
}
