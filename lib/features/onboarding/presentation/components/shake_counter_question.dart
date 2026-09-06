// ============================================================================
// SHAKE COUNTER QUESTION
// ============================================================================
// Displays the shake-driven counter with a pulse animation.
// Pure display widget: all counting logic lives in YearViewModel.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/year_viewmodel.dart';

class ShakeCounterQuestion extends StatefulWidget {
  final String question;
  final YearViewModel viewModel;
  final VoidCallback onConfirm;

  const ShakeCounterQuestion({
    super.key,
    required this.question,
    required this.viewModel,
    required this.onConfirm,
  });

  @override
  State<ShakeCounterQuestion> createState() => _ShakeCounterQuestionState();
}

class _ShakeCounterQuestionState extends State<ShakeCounterQuestion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  int _lastCounter = 0;

  @override
  void initState() {
    super.initState();
    _lastCounter = widget.viewModel.counter;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    widget.viewModel.addListener(_onViewModelChanged);
  }

  // --- Trigger the pulse animation whenever the counter increases ---
  void _onViewModelChanged() {
    if (widget.viewModel.counter > _lastCounter) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
    _lastCounter = widget.viewModel.counter;
    setState(() {});
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _pulseController.dispose();
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuestion(context),
            _buildCounter(),
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        widget.question,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF2D2D2D),
              fontWeight: FontWeight.w300,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCounter() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value,
        child: Text(
          '${widget.viewModel.counter}',
          style: const TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w900,
            color: amorPink,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          AnimatedOpacity(
            opacity: widget.viewModel.showWarning ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Presque... réessaie ! 🌹',
                style: TextStyle(color: amorPink, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: widget.viewModel.reset,
                child:
                    const Text('Reset', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.viewModel.validate()) widget.onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amorPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Valider',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}