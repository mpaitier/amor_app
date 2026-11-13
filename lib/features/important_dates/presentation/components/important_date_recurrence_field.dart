// ============================================================================
// IMPORTANT DATE RECURRENCE FIELD
// ============================================================================
// Ligne de répétition : la règle ("Tous les ans") et un interrupteur.
// Coupée, la règle reste affichée en gris. Activée, elle s'anime et un tap
// dessus ouvre la boîte de dialogue pour la modifier.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/recurrence_rule.dart';
import '../utils/important_date_labels.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';
import 'important_date_recurrence_dialog.dart';

class ImportantDateRecurrenceField extends StatelessWidget {
  const ImportantDateRecurrenceField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();
    final isActive = viewModel.repeats;
    final color = isActive ? amorDarkRose : outlineLight;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: outlineLight),
    );

    return Material(
      color: Colors.white,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // --- La règle : grisée et inerte tant que la répétition est coupée ---
          Expanded(
            child: InkWell(
              onTap: isActive ? () => _editRule(context, viewModel) : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                child: Row(
                  children: [
                    Icon(Icons.repeat, color: color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recurrenceSummary(
                          viewModel.recurrence,
                          viewModel.occurrenceLimit,
                        ),
                        style: TextStyle(
                          color: isActive ? onBackgroundLight : outlineLight,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isActive)
                      const Icon(
                        Icons.chevron_right,
                        color: amorDarkRose,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Switch(
              value: isActive,
              onChanged: viewModel.setRepeats,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editRule(
    BuildContext context,
    AddEditImportantDateViewModel viewModel,
  ) async {
    final rule = await showDialog<RecurrenceRule>(
      context: context,
      builder: (_) => ImportantDateRecurrenceDialog(
        initialRule: RecurrenceRule(
          recurrence: viewModel.recurrence,
          occurrenceLimit: viewModel.occurrenceLimit,
        ),
      ),
    );
    if (rule != null) viewModel.setRecurrenceRule(rule);
  }
}
