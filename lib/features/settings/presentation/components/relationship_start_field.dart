// ============================================================================
// RELATIONSHIP START FIELD
// ============================================================================
// Le jour où l'histoire a commencé. Un tap ouvre le sélecteur de date.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../important_dates/presentation/components/important_date_date_field.dart';
import '../viewmodels/settings_viewmodel.dart';

class RelationshipStartField extends StatelessWidget {
  const RelationshipStartField({super.key});

  // --- Plus loin que ça, ce n'est sans doute pas une date voulue ---
  static const int _yearsBack = 80;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

    return ImportantDateDateField(
      date: viewModel.settings.relationshipStart,
      onTap: () => _pickDate(context, viewModel),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final today = viewModel.today;
    final current = viewModel.settings.relationshipStart;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isAfter(today) ? today : current,
      firstDate: DateTime(today.year - _yearsBack),
      lastDate: today,
    );
    if (picked != null) await viewModel.setRelationshipStart(picked);
  }
}
