// <<===========================================================================>>
// <<========================= COLONNE DATE TIMELINE ===========================>>
// <<===========================================================================>>
// Équivalent de Date.kt — affichage de la date d'un événement

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/timeline_event.dart';

class TimelineDateColumn extends StatelessWidget {
  // <<--- Paramètres --->
  final TimelineEvent event;

  const TimelineDateColumn({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: amorDarkRose, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // <<--- Mois --->
          _buildMonth(),

          // <<--- Jour --->
          _buildDay(),

          // <<--- Année --->
          _buildYear(),
        ],
      ),
    );
  }

  // <<--- Section Mois --->
  Widget _buildMonth() {
    final month = DateFormat('MMM', 'fr_FR')
        .format(event.date)
        .toUpperCase();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFC6C6C6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        month,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF424242),
        ),
      ),
    );
  }

  // <<--- Section Jour --->
  Widget _buildDay() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '${event.date.day}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: amorDarkRose,
        ),
      ),
    );
  }

  // <<--- Section Année --->
  Widget _buildYear() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '${event.date.year}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF424242),
        ),
      ),
    );
  }
}