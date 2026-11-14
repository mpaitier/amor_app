// ============================================================================
// COUPLE SETUP CARD
// ============================================================================
// Carte blanche de l'écran de création : mode, surnom, couleur, code (en
// mode "Rejoindre") et bouton de validation. Branchée sur le
// CoupleSetupViewModel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/components/auth_message_banner.dart';
import '../../../auth/presentation/components/auth_submit_button.dart';
import '../../../auth/presentation/components/auth_text_field.dart';
import '../viewmodels/couple_setup_viewmodel.dart';
import 'couple_setup_mode_switch.dart';
import 'invite_code_input.dart';
import 'member_color_picker.dart';

class CoupleSetupCard extends StatelessWidget {
  const CoupleSetupCard({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CoupleSetupViewModel>();
    final isEnabled = !viewModel.isBusy;

    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CoupleSetupModeSwitch(
              mode: viewModel.mode,
              enabled: isEnabled,
              onModeChanged: viewModel.selectMode,
            ),
            const SizedBox(height: 16),
            if (viewModel.errorMessage != null) ...[
              AuthMessageBanner(
                message: viewModel.errorMessage!,
                isError: true,
              ),
              const SizedBox(height: 12),
            ],
            if (viewModel.isJoining) ...[
              InviteCodeInput(
                controller: viewModel.codeController,
                enabled: isEnabled,
              ),
              const SizedBox(height: 12),
            ],
            AuthTextField(
              controller: viewModel.nicknameController,
              label: 'Ton surnom',
              icon: Icons.badge_outlined,
              enabled: isEnabled,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ta couleur',
              style: TextStyle(
                color: amorDarkRose,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            MemberColorPicker(
              selectedColor: viewModel.selectedColor,
              enabled: isEnabled,
              onColorSelected: viewModel.selectColor,
            ),
            const SizedBox(height: 20),
            AuthSubmitButton(
              label: viewModel.isJoining
                  ? 'Rejoindre la relation'
                  : 'Créer notre relation',
              isBusy: viewModel.isBusy,
              onPressed: viewModel.submit,
            ),
          ],
        ),
      ),
    );
  }
}
