// ============================================================================
// MOTION REPOSITORY (INTERFACE)
// ============================================================================
// Exposes device motion as a normalized acceleration magnitude stream
// (1.0 == standing still under Earth's gravity).

abstract class MotionRepository {
  Stream<double> watchAccelerationMagnitude();
}