// ============================================================================
// ANSWER REVIEW
// ============================================================================
// Confirmation animation for the name-question answer: hearts intro,
// then a "runaway modify button vs growing confirm button" mini-game.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnswerReview extends StatefulWidget {
  final String answer;
  final VoidCallback onConfirm;
  final VoidCallback onModify;

  const AnswerReview({
    super.key,
    required this.answer,
    required this.onConfirm,
    required this.onModify,
  });

  @override
  State<AnswerReview> createState() => _AnswerReviewState();
}

class _AnswerReviewState extends State<AnswerReview> {
  // --- Animation phases ---
  int _phase = 0;
  int _visibleHearts = 0;
  int _modifyClickCount = 0;

  @override
  void initState() {
    super.initState();
    _runIntroSequence();
  }

  // --- Intro sequence ---
  Future<void> _runIntroSequence() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _visibleHearts++);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _phase = 1);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _phase = 2);
  }

  @override
  Widget build(BuildContext context) {
    // --- Modify-button animation values ---
    final modifyScale = _modifyClickCount > 0
        ? (1.0 - _modifyClickCount * 0.2).clamp(0.4, 1.0)
        : 1.0;
    final confirmScale = (1.0 + _modifyClickCount * 0.25).clamp(1.0, 1.5);
    final modifyOffsetX = -(_modifyClickCount * 50.0);
    final modifyOffsetY = _modifyClickCount * 60.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [amorBackground, amorBackgroundEnd],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // --- Animated hearts ---
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedOpacity(
                      opacity:
                          (_visibleHearts > index && _phase < 2) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('❤️', style: TextStyle(fontSize: 32)),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // --- Transition text ---
              AnimatedOpacity(
                opacity: _phase >= 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: const Text(
                  'Votre nom est bien...',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              // --- Answer ---
              AnimatedOpacity(
                opacity: _phase >= 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  widget.answer,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: amorPink,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 10),

              // --- Mascot image ---
              AnimatedOpacity(
                opacity: _phase >= 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: Image.asset(
                  'assets/images/lulu_amor.png',
                  width: 220,
                  height: 220,
                ),
              ),

              const SizedBox(height: 24),

              // --- Buttons, inside a SizedBox that allows overflow ---
              AnimatedOpacity(
                opacity: _phase >= 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Stack(
                    // --- clipBehavior none lets the button run off-screen ---
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // --- "Modify" button (runs away) ---
                      Positioned(
                        left: 0,
                        top: 120,
                        child: Transform.translate(
                          offset: Offset(modifyOffsetX, modifyOffsetY),
                          child: Transform.scale(
                            scale: modifyScale,
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => _modifyClickCount++),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Modifier',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // --- "Confirm" button (grows, stays centered) ---
                      Transform.scale(
                        scale: confirmScale,
                        child: ElevatedButton(
                          onPressed: widget.onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: amorPink,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Confirmer',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}