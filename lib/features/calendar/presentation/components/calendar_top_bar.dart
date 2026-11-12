// ============================================================================
// CALENDAR TOP BAR
// ============================================================================
// Titre centré, même habillage que TimelineTopBar pour rester cohérent
// visuellement entre les deux écrans principaux.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CalendarTopBar extends StatelessWidget {
  const CalendarTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          color: amorCreamTransparent,
          child: const Text(
            'Calendrier',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF703348),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              decorationColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}