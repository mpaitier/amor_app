// ============================================================================
// YEAR SCREEN
// ============================================================================
// Shake-to-count question about the relationship's duration.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../viewmodels/year_viewmodel.dart';
import '../components/shake_counter_question.dart';

class YearScreen extends StatelessWidget {
  const YearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => YearViewModel(watchShakeEvents: sl.watchShakeEvents),
      child: Scaffold(
        body: SafeArea(
          child: Consumer<YearViewModel>(
            builder: (context, viewModel, _) => ShakeCounterQuestion(
              question:
                  'Depuis combien d\'années sommes-nous ensembles ?\n(secoue pour augmenter)',
              viewModel: viewModel,
              onConfirm: () => context.go(AppRoutes.gift),
            ),
          ),
        ),
      ),
    );
  }
}