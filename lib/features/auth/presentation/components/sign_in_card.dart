// ============================================================================
// SIGN IN CARD
// ============================================================================
// Carte blanche de l'écran de connexion : message, formulaire e-mail,
// bascule de mode, puis Google. Branchée sur le SignInViewModel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sign_in_viewmodel.dart';
import 'auth_divider.dart';
import 'auth_message_banner.dart';
import 'auth_mode_switch.dart';
import 'auth_submit_button.dart';
import 'email_password_form.dart';
import 'forgot_password_button.dart';
import 'google_sign_in_button.dart';

class SignInCard extends StatelessWidget {
  const SignInCard({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignInViewModel>();

    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (viewModel.errorMessage != null) ...[
              AuthMessageBanner(
                message: viewModel.errorMessage!,
                isError: true,
              ),
              const SizedBox(height: 12),
            ],
            if (viewModel.infoMessage != null) ...[
              AuthMessageBanner(
                message: viewModel.infoMessage!,
                isError: false,
              ),
              const SizedBox(height: 12),
            ],
            const EmailPasswordForm(),
            if (viewModel.isRegistering)
              const SizedBox(height: 16)
            else
              ForgotPasswordButton(
                isBusy: viewModel.isBusy,
                onPressed: viewModel.resetPassword,
              ),
            AuthSubmitButton(
              label: viewModel.isRegistering ? 'Créer mon compte' : 'Se connecter',
              isBusy: viewModel.isBusy,
              onPressed: viewModel.submitEmail,
            ),
            const SizedBox(height: 4),
            AuthModeSwitch(
              isRegistering: viewModel.isRegistering,
              isBusy: viewModel.isBusy,
              onToggle: viewModel.toggleMode,
            ),
            const SizedBox(height: 4),
            const AuthDivider(),
            const SizedBox(height: 16),
            GoogleSignInButton(
              isBusy: viewModel.isBusy,
              onPressed: viewModel.continueWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}
