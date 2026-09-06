// ============================================================================
// ROOT APP WIDGET
// ============================================================================

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

class AmorApp extends StatelessWidget {
  const AmorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // --- Base configuration ---
      title: 'Amor',
      debugShowCheckedModeBanner: false,

      // --- Themes ---
      theme: amorLightTheme,
      darkTheme: amorDarkTheme,
      themeMode: ThemeMode.light,

      // --- Navigation ---
      routerConfig: appRouter,

      // --- Builder: global background + SafeArea ---
      builder: (context, child) {
        return Stack(
          children: [
            // --- Global background image ---
            Positioned.fill(
              child: Image.asset(
                'assets/images/amor_background.png',
                fit: BoxFit.cover,
              ),
            ),

            // --- App content on top ---
            SafeArea(
              child: child ?? const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}