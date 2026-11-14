// ============================================================================
// MEMBER PROFILE EDITOR
// ============================================================================
// Bloc "Mon profil" des paramètres : surnom (enregistré en quittant le
// champ) et couleur (enregistrée au toucher). Branché sur le
// MemberProfileViewModel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/components/auth_text_field.dart';
import '../viewmodels/member_profile_viewmodel.dart';
import 'member_color_picker.dart';

class MemberProfileEditor extends StatefulWidget {
  const MemberProfileEditor({super.key});

  @override
  State<MemberProfileEditor> createState() => _MemberProfileEditorState();
}

class _MemberProfileEditorState extends State<MemberProfileEditor> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        context.read<MemberProfileViewModel>().saveNickname();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MemberProfileViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewModel.errorMessage != null) ...[
          Text(
            viewModel.errorMessage!,
            style: const TextStyle(color: errorLight),
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          focusNode: _focusNode,
          child: AuthTextField(
            controller: viewModel.nicknameController,
            label: 'Surnom',
            icon: Icons.badge_outlined,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text(
              'Couleur',
              style: TextStyle(
                color: amorDarkRose,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (viewModel.isSaving)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: amorPink,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        MemberColorPicker(
          selectedColor: viewModel.selectedColor,
          onColorSelected: viewModel.selectColor,
        ),
      ],
    );
  }
}
