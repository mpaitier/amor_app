// ============================================================================
// COUPLE SETUP CARD
// ============================================================================
// Carte blanche de l'écran de création : mode, code (en mode "Rejoindre"),
// date de début (en mode "Créer"), surnom, couleur et bouton de
// validation. Branchée sur le CoupleSetupViewModel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/components/auth_message_banner.dart';
import '../../../auth/presentation/components/auth_submit_button.dart';
import '../../../auth/presentation/components/auth_text_field.dart';
import '../viewmodels/couple_setup_viewmodel.dart';
import 'couple_setup_mode_switch.dart';
import 'couple_start_date_field.dart';
import 'invite_code_input.dart';
import 'member_color_picker.dart';

class CoupleSetupCard extends StatelessWidget {
  const CoupleSetupCard({super.key});

  // --- Plus loin que ça, ce n'est sans doute pas une date voulue ---
  static const int _yearsBack = 80;

  Future<void> _pickStartDate(
    BuildContext context,
    CoupleSetupViewModel viewModel,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.relationshipStart ?? today,
      firstDate: DateTime(today.year - _yearsBack),
      lastDate: today,
      helpText: 'Votre histoire a commencé le',
    );
    if (picked != null) viewModel.setRelationshipStart(picked);
  }

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
            ] else ...[
              const Text(
                'Votre histoire a commencé le',
                style: TextStyle(
                  color: amorDarkRose,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              CoupleStartDateField(
                date: viewModel.relationshipStart,
                enabled: isEnabled,
                onTap: () => _pickStartDate(context, viewModel),
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
