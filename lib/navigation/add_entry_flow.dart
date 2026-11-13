// ============================================================================
// ADD ENTRY FLOW
// ============================================================================
// Ce que déclenche le bouton + du journal et du calendrier : on demande
// d'abord quoi ajouter, puis on ouvre le formulaire correspondant.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/add_entry_sheet.dart';
import 'app_routes.dart';

Future<void> openAddEntryFlow(BuildContext context) async {
  final choice = await showModalBottomSheet<AddEntryChoice>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const AddEntrySheet(),
  );

  if (choice == null || !context.mounted) return;

  if (choice == AddEntryChoice.memory) {
    context.push(AppRoutes.addTimeline);
  } else {
    context.push(AppRoutes.addImportantDate);
  }
}
