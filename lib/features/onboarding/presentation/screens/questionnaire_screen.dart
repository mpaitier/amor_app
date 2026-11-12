// ============================================================================
// QUESTIONNAIRE SCREEN
// ============================================================================
// Orchestrates the onboarding name-question steps.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../navigation/app_routes.dart';
import '../viewmodels/questionnaire_viewmodel.dart';
import '../components/fake_question.dart';
import '../components/answer_review.dart';

class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuestionnaireViewModel(),
      child: const _QuestionnaireView(),
    );
  }
}

// --- Separate widget so its BuildContext sits below the provider ---
// --- (same pattern as GiftScreen / AddEventScreen). Reading the ViewModel
// --- from QuestionnaireScreen's own context throws ProviderNotFoundException,
// --- because that context is the provider's parent.
class _QuestionnaireView extends StatelessWidget {
  const _QuestionnaireView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildStep(context)),
    );
  }

  Widget _buildStep(BuildContext context) {
    final viewModel = context.watch<QuestionnaireViewModel>();

    switch (viewModel.step) {
      case QuestionStep.input:
        return FakeQuestion(
          question: QuestionnaireViewModel.questionText,
          predefinedAnswer: QuestionnaireViewModel.predefinedAnswer,
          onAnswerSubmitted: viewModel.submitAnswer,
        );

      case QuestionStep.review:
        return AnswerReview(
          answer: viewModel.answer,
          onConfirm: () => context.go(AppRoutes.yearQuestion),
          onModify: viewModel.modifyAnswer,
        );

      case QuestionStep.completed:
        return const Center(child: Text('Questionnaire terminé !'));
    }
  }
}
