// ============================================================================
// EVENT DATE + PLACE CARD
// ============================================================================
// NOTE: depends on PlaceAutocompleteField from the "place" feature,
// created in a later step of the refactor.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../place/presentation/components/place_autocomplete_field.dart';
import '../viewmodels/add_edit_event_viewmodel.dart';

class EventDatePlaceCard extends StatelessWidget {
  const EventDatePlaceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditEventViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: amorCream,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _pickDate(context, viewModel),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${viewModel.selectedDate.day.toString().padLeft(2, '0')}/'
                  '${viewModel.selectedDate.month.toString().padLeft(2, '0')}/'
                  '${viewModel.selectedDate.year}',
                  style: const TextStyle(color: Color(0xFF616161)),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          PlaceAutocompleteField(
            initialValue: viewModel.currentPlace,
            onPlaceSelected: viewModel.setPlace,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    AddEditEventViewModel viewModel,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) viewModel.setDate(picked);
  }
}