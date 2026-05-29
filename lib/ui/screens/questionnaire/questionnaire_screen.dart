// <<===========================================================================>>
// <<========================= ÉCRAN QUESTIONNAIRE =============================>>
// <<===========================================================================>>
// Équivalent de QuestionnaryScreen.kt — orchestration des étapes du questionnaire

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/question_state.dart';
import '../../../navigation/screen.dart';
import '../../components/questionnaire/fake_question.dart';
import '../../components/questionnaire/answer_review.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  // <<--- État courant du questionnaire --->
  QuestionState _currentState = QuestionState.input;

  // <<--- Réponse actuelle --->
  String _currentAnswer = '';

  // <<--- Textes --->
  static const String _questionText =
      'Quel est le nom de la femme de la vie de Titi el oso ?';
  static const String _predefinedAnswer =
      'Luluchita la tarte au citron meringuée d\'amour';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildCurrentStep(context),
      ),
    );
  }

  // <<--- Construction de l'étape courante --->
  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentState) {
      // <<--- Étape 1 : Saisie --->
      case QuestionState.input:
        return FakeQuestion(
          question: _questionText,
          predefinedAnswer: _predefinedAnswer,
          onAnswerSubmitted: (answer) {
            setState(() {
              _currentAnswer = answer;
              _currentState = QuestionState.review;
            });
          },
        );

      // <<--- Étape 2 : Revue --->
      case QuestionState.review:
        return AnswerReview(
          answer: _currentAnswer.isEmpty ? _predefinedAnswer : _currentAnswer,
          onConfirm: () => context.go(AppRoutes.yearQuestion),
          onModify: () => setState(() => _currentState = QuestionState.input),
        );

      // <<--- Étape 3 : Terminé --->
      case QuestionState.completed:
        return const Center(child: Text('Questionnaire terminé !'));
    }
  }
}