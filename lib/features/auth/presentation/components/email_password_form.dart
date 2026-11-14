// ============================================================================
// EMAIL PASSWORD FORM
// ============================================================================
// E-mail, mot de passe, et confirmation en mode création de compte. Les
// contrôleurs appartiennent au SignInViewModel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sign_in_viewmodel.dart';
import 'auth_text_field.dart';

class EmailPasswordForm extends StatelessWidget {
  const EmailPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignInViewModel>();
    final isEnabled = !viewModel.isBusy;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: viewModel.emailController,
            label: 'Adresse e-mail',
            icon: Icons.mail_outline,
            enabled: isEnabled,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: viewModel.passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
            enabled: isEnabled,
            autofillHints: [
              viewModel.isRegistering
                  ? AutofillHints.newPassword
                  : AutofillHints.password,
            ],
            textInputAction: viewModel.isRegistering
                ? TextInputAction.next
                : TextInputAction.done,
            onSubmitted:
                viewModel.isRegistering ? null : (_) => viewModel.submitEmail(),
          ),
          if (viewModel.isRegistering) ...[
            const SizedBox(height: 12),
            AuthTextField(
              controller: viewModel.confirmationController,
              label: 'Confirme le mot de passe',
              icon: Icons.lock_reset,
              isPassword: true,
              enabled: isEnabled,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => viewModel.submitEmail(),
            ),
          ],
        ],
      ),
    );
  }
}
