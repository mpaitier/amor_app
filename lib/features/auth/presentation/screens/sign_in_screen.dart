// ============================================================================
// SIGN IN SCREEN
// ============================================================================
// Premier écran quand personne n'est connecté. Une fois la connexion
// réussie, GoRouter quitte cet écran de lui-même.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../components/auth_header.dart';
import '../components/sign_in_card.dart';
import '../viewmodels/sign_in_viewmodel.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignInViewModel(
        signInWithGoogle: sl.signInWithGoogle,
        signInWithEmail: sl.signInWithEmail,
        registerWithEmail: sl.registerWithEmail,
        sendPasswordReset: sl.sendPasswordReset,
      ),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeader(),
                SizedBox(height: 28),
                SignInCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
