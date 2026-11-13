// ============================================================================
// IMPORTANT DATE RECURRENCE FIELD
// ============================================================================
// Interrupteur de répétition. Une fois activé, il part sur "Tous les ans"
// et laisse choisir une autre fréquence.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/important_date_palette.dart';
import '../utils/important_date_labels.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';

class ImportantDateRecurrenceField extends StatelessWidget {
  const ImportantDateRecurrenceField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: outlineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToggle(viewModel),
          if (viewModel.repeats) _buildFrequencies(viewModel),
        ],
      ),
    );
  }

  Widget _buildToggle(AddEditImportantDateViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 6, 2),
      child: Row(
        children: [
          const Icon(Icons.repeat, color: amorDarkRose, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Répéter',
              style: TextStyle(color: onBackgroundLight, fontSize: 16),
            ),
          ),
          Switch(
            value: viewModel.repeats,
            onChanged: viewModel.setRepeats,
          ),
        ],
      ),
    );
  }

  // --- Fréquences proposées, celle retenue est cochée ---
  Widget _buildFrequencies(AddEditImportantDateViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Wrap(
        spacing: 8,
        children: [
          for (final recurrence in ImportantDatePalette.recurrences)
            ChoiceChip(
              label: Text(recurrenceLabel(recurrence)),
              selected: viewModel.recurrence == recurrence,
              onSelected: (_) => viewModel.setRecurrence(recurrence),
            ),
        ],
      ),
    );
  }
}
