// ============================================================================
// MOTION DATA SOURCE
// ============================================================================
// Wraps the raw accelerometer sensor stream.

import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class MotionDataSource {
  Stream<double> watchAccelerationMagnitude() {
    return accelerometerEventStream().map((event) {
      return sqrt(event.x * event.x + event.y * event.y + event.z * event.z) /
          9.81;
    });
  }
}