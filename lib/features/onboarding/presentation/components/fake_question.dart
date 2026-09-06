// ============================================================================
// FAKE QUESTION
// ============================================================================
// Name entry step of the onboarding questionnaire.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FakeQuestion extends StatefulWidget {
  final String question;
  final String predefinedAnswer;
  final void Function(String answer) onAnswerSubmitted;

  const FakeQuestion({
    super.key,
    required this.question,
    required this.predefinedAnswer,
    required this.onAnswerSubmitted,
  });

  @override
  State<FakeQuestion> createState() => _FakeQuestionState();
}

class _FakeQuestionState extends State<FakeQuestion> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [amorBackground, amorBackgroundEnd],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/titi_oso.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.question,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Ton nom',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () =>
                            widget.onAnswerSubmitted(widget.predefinedAnswer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: amorPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continuer',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}