// ============================================================================
// COUPLE SETUP SCREEN
// ============================================================================
// Affiché à une personne connectée qui n'a pas encore de relation. Une
// fois la relation créée ou rejointe, GoRouter quitte cet écran de
// lui-même.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../components/couple_setup_card.dart';
import '../components/couple_setup_header.dart';
import '../components/setup_sign_out_button.dart';
import '../models/pending_invite.dart';
import '../viewmodels/couple_setup_viewmodel.dart';

class CoupleSetupScreen extends StatelessWidget {
  const CoupleSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoupleSetupViewModel(
        createCouple: sl.createCouple,
        joinCouple: sl.joinCouple,
        pendingInvite: context.read<PendingInvite>(),
      ),
      child: const _CoupleSetupView(),
    );
  }
}

class _CoupleSetupView extends StatelessWidget {
  const _CoupleSetupView();

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
                CoupleSetupHeader(),
                SizedBox(height: 24),
                CoupleSetupCard(),
                SizedBox(height: 12),
                SetupSignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
