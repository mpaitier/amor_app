// ============================================================================
// IMPORTANT DATE SHEET
// ============================================================================
// Fiche ouverte par un tap sur une date importante : emoji, titre, jour,
// temps restant, puis les actions. Se ferme en renvoyant l'action choisie.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/important_date_entity.dart';
import '../utils/important_date_labels.dart';

enum ImportantDateAction { edit, delete }

class ImportantDateSheet extends StatelessWidget {
  final ImportantDateEntity date;

  // --- Le jour touché : pour une date répétée, l'année de la case ---
  final DateTime occurrence;
  final DateTime today;

  const ImportantDateSheet({
    super.key,
    required this.date,
    required this.occurrence,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMMM yyyy', 'fr_FR');
    final dayLabel = date.repeats
        ? '${formatter.format(occurrence)} · '
            '${recurrenceLabel(date.recurrence).toLowerCase()}'
        : formatter.format(occurrence);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 16),
            Text(date.emoji, style: const TextStyle(fontSize: 40, height: 1.0)),
            const SizedBox(height: 12),
            Text(
              date.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: amorDarkRose,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dayLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              formatCountdown(occurrence, today),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: onBackgroundLight,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: outlineVariantLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () =>
                Navigator.of(context).pop(ImportantDateAction.delete),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(context).pop(ImportantDateAction.edit),
            icon: const Icon(Icons.edit_outlined, color: amorDarkRose),
            label: const Text(
              'Modifier',
              style: TextStyle(color: amorDarkRose),
            ),
          ),
        ),
      ],
    );
  }
}
