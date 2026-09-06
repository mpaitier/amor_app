// ============================================================================
// USE CASE: WATCH SHAKE EVENTS
// ============================================================================
// Emits an event each time a shake gesture crosses the threshold,
// debounced so a single physical shake doesn't fire multiple times.

import '../repositories/motion_repository.dart';

class WatchShakeEvents {
  final MotionRepository _repository;
  static const double _shakeThreshold = 2.7;
  static const int _shakeSlopMs = 500;

  const WatchShakeEvents(this._repository);

  Stream<void> call() {
    int lastShakeTime = 0;

    return _repository.watchAccelerationMagnitude().where((gForce) {
      if (gForce <= _shakeThreshold) return false;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastShakeTime <= _shakeSlopMs) return false;
      lastShakeTime = now;
      return true;
    });
  }
}