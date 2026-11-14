// ============================================================================
// SPLASH SCREEN
// ============================================================================
// Affiché le temps que Firebase dise si quelqu'un est déjà connecté.
// Ne dure en général qu'une fraction de seconde.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/amorapp.png',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: amorPink),
          ],
        ),
      ),
    );
  }
}
