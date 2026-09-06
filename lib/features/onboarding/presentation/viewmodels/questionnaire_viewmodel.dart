// ============================================================================
// QUESTIONNAIRE VIEWMODEL
// ============================================================================
// Handles the name-question step state machine (input -> review -> completed).

import 'package:flutter/material.dart';

enum QuestionStep { input, review, completed }

class QuestionnaireViewModel extends ChangeNotifier {
  static const String questionText =
      'Quel est le nom de la femme de la vie de Titi el oso ?';
  static const String predefinedAnswer =
      'Luluchita la tarte au citron meringuée d\'amour';

  QuestionStep _step = QuestionStep.input;
  String _answer = '';

  QuestionStep get step => _step;
  String get answer => _answer.isEmpty ? predefinedAnswer : _answer;

  // --- Submit the answer and move to the review step ---
  void submitAnswer(String answer) {
    _answer = answer;
    _step = QuestionStep.review;
    notifyListeners();
  }

  // --- Go back to editing the answer ---
  void modifyAnswer() {
    _step = QuestionStep.input;
    notifyListeners();
  }
}