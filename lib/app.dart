// <<===========================================================================>>
// <<============================== APP PRINCIPALE =============================>>
// <<===========================================================================>>

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

class AmorApp extends StatelessWidget {
  const AmorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // <<--- Configuration de base --->
      title: 'Amor',
      debugShowCheckedModeBanner: false,

      // <<--- Thèmes --->
      theme: amorLightTheme,
      darkTheme: amorDarkTheme,
      themeMode: ThemeMode.light,

      // <<--- Navigation --->
      routerConfig: appRouter,

      // <<--- Builder : fond global + SafeArea --->
      builder: (context, child) {
        return Stack(
          children: [
            // <<--- Image de fond globale (amor_background) --->
            Positioned.fill(
              child: Image.asset(
                'assets/images/amor_background.png',
                fit: BoxFit.cover,
              ),
            ),

            // <<--- Contenu de l'app par-dessus --->
            SafeArea(
              child: child ?? const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}