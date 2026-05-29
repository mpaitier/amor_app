// <<===========================================================================>>
// <<========================= ÉCRAN ANNÉE =====================================>>
// <<===========================================================================>>
// Équivalent de YearScreen.kt — question par secousse sur les années

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../navigation/screen.dart';
import '../../components/questionnaire/number_question.dart';

class YearScreen extends StatelessWidget {
  const YearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // <<--- Correction : le widget s'appelle ShakeCounterQuestion --->
        child: ShakeCounterQuestion(
          question: 'Depuis combien d\'années sommes-nous ensembles ?\n(secoue pour augmenter)',
          onConfirm: (answer) => context.go(AppRoutes.gift),
        ),
      ),
    );
  }
}