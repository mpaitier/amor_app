// <<===========================================================================>>
// <<============================== APP PRINCIPALE =============================>>
// <<===========================================================================>>
// Équivalent de AmorApp dans MainActivity.kt — racine de l'application

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
    );
  }
}