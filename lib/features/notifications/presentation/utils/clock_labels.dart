// ============================================================================
// CLOCK LABELS
// ============================================================================

// --- Minutes depuis minuit -> "09:00" ---
String formatClock(int minutes) {
  final hours = (minutes ~/ 60).toString().padLeft(2, '0');
  final rest = (minutes % 60).toString().padLeft(2, '0');
  return '$hours:$rest';
}
