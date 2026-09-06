// ============================================================================
// EVENT "CREATED BY" SELECTOR
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/add_edit_event_viewmodel.dart';

class EventWhoSelector extends StatelessWidget {
  const EventWhoSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditEventViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: amorCream,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Créé par : ',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          for (final option in ['Lulu', 'Titi'])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                selected: viewModel.selectedWho == option,
                label: Text(option),
                onSelected: (_) => viewModel.setWho(option),
              ),
            ),
        ],
      ),
    );
  }
}