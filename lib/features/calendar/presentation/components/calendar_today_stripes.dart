// ============================================================================
// CALENDAR TODAY STRIPES
// ============================================================================
// Rayures en diagonale pour le fond de la case d'aujourd'hui, qu'on la
// distingue au premier coup d'œil des jours spéciaux, eux aussi bordés.

import 'package:flutter/material.dart';

class CalendarTodayStripes extends StatelessWidget {
  final Color color;

  const CalendarTodayStripes({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StripesPainter(color));
  }
}

class _StripesPainter extends CustomPainter {
  // --- Écart entre deux rayures, mesuré le long du bord ---
  static const double _spacing = 7;

  final Color color;

  const _StripesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5;

    // --- Lignes à 45° qui balaient toute la case ---
    for (var x = -size.height; x < size.width; x += _spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) => oldDelegate.color != color;
}
