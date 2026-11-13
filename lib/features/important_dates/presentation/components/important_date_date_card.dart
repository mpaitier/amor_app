// ============================================================================
// IMPORTANT DATE DATE CARD
// ============================================================================
// Choix du jour (qui peut être à venir) et de la répétition annuelle.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';

class ImportantDateDateCard extends StatelessWidget {
  const ImportantDateDateCard({super.key});

  // --- Bornes du sélecteur, en années autour d'aujourd'hui ---
  static const int _yearsBack = 100;
  static const int _yearsAhead = 20;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();

    // --- Material plutôt que Container : l'effet d'encre du tap se dessine
    // --- ainsi par-dessus le fond crème ---
    return Material(
      color: amorCream,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildDayRow(context, viewModel),
          const Divider(height: 1, indent: 12, endIndent: 12),
          _buildRepeatRow(viewModel),
        ],
      ),
    );
  }

  // --- Jour choisi ; un tap ouvre le sélecteur de date ---
  Widget _buildDayRow(
    BuildContext context,
    AddEditImportantDateViewModel viewModel,
  ) {
    final formatter = DateFormat('d MMMM yyyy', 'fr_FR');

    return InkWell(
      onTap: () => _pickDate(context, viewModel),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(
              formatter.format(viewModel.selectedDate),
              style: const TextStyle(color: Color(0xFF616161)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Répétition annuelle ---
  Widget _buildRepeatRow(AddEditImportantDateViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
      child: Row(
        children: [
          const Icon(Icons.repeat, color: Colors.grey, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Se répète chaque année',
              style: TextStyle(color: Color(0xFF616161)),
            ),
          ),
          Switch(
            value: viewModel.repeatsYearly,
            onChanged: viewModel.setRepeatsYearly,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    AddEditImportantDateViewModel viewModel,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(now.year - _yearsBack),
      lastDate: DateTime(now.year + _yearsAhead, 12, 31),
    );
    if (picked != null) viewModel.setDate(picked);
  }
}
