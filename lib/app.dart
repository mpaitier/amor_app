// ============================================================================
// ROOT APP WIDGET
// ============================================================================
// Crée le routeur une seule fois, branché sur la session (connexion et
// relation) et sur le code d'invitation en attente, fournis par main.dart.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'couple_scoped_providers.dart';
import 'features/couple/presentation/models/pending_invite.dart';
import 'features/couple/presentation/viewmodels/couple_session_viewmodel.dart';
import 'navigation/app_router.dart';

class AmorApp extends StatefulWidget {
  const AmorApp({super.key});

  @override
  State<AmorApp> createState() => _AmorAppState();
}

class _AmorAppState extends State<AmorApp> {
  // --- Un seul routeur pour toute la vie de l'app : le recréer ferait
  // --- perdre la pile de navigation ---
  late final GoRouter _router = createAppRouter(
    session: context.read<CoupleSessionViewModel>(),
    pendingInvite: context.read<PendingInvite>(),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

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
      routerConfig: _router,

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

            // --- App content on top, with the ViewModels of the active
            // --- relationship available to every screen ---
            SafeArea(
              child: CoupleScopedProviders(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
