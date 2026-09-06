// ============================================================================
// YEAR VIEWMODEL
// ============================================================================
// Counts shake gestures and validates the count against the real
// number of elapsed years.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/watch_shake_events.dart';

class YearViewModel extends ChangeNotifier {
  final WatchShakeEvents _watchShakeEvents;
  StreamSubscription<void>? _subscription;

  int counter = 0;
  bool showWarning = false;

  YearViewModel({required WatchShakeEvents watchShakeEvents})
      : _watchShakeEvents = watchShakeEvents {
    _subscription = _watchShakeEvents().listen((_) => _onShake());
  }

  void _onShake() {
    counter++;
    showWarning = false;
    notifyListeners();
  }

  void reset() {
    counter = 0;
    notifyListeners();
  }

  // --- Validate the answer; returns true if it matches the real elapsed years ---
  bool validate() {
    if (counter == elapsedYears) return true;
    showWarning = true;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}