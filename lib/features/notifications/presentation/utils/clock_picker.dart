// ============================================================================
// CLOCK PICKER
// ============================================================================
// Ouvre le sélecteur d'heure en format 24 h. Renvoie l'heure choisie en
// minutes depuis minuit, ou null si l'on annule.

import 'package:flutter/material.dart';

Future<int?> pickClockTime(BuildContext context, int minutes) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    // --- Format 24 h, quelle que soit la langue du téléphone ---
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  return picked == null ? null : picked.hour * 60 + picked.minute;
}
