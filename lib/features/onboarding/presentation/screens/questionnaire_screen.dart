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
      child: Scaffold(
        body: SafeArea(child: _buildStep(context)),
      ),
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