// ============================================================================
// GIFT VIEWMODEL
// ============================================================================
// Handles the final gift reveal sequence and onboarding completion.

import 'package:flutter/material.dart';
import '../../domain/usecases/complete_onboarding.dart';

class GiftViewModel extends ChangeNotifier {
  final CompleteOnboarding _completeOnboarding;

  bool showButton = false;
  int clickCount = 0;

  GiftViewModel({required CompleteOnboarding completeOnboarding})
      : _completeOnboarding = completeOnboarding {
    _startSequence();
  }

  // --- Reveal the gift button after a short delay ---
  Future<void> _startSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    showButton = true;
    notifyListeners();
  }

  // --- Handle a tap on the gift; returns true once onboarding is complete ---
  Future<bool> onGiftTap() async {
    if (clickCount < 2) {
      clickCount++;
      notifyListeners();
      return false;
    }
    await _completeOnboarding();
    return true;
  }
}