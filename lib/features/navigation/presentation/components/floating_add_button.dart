// ============================================================================
// FLOATING ADD BUTTON
// ============================================================================
// Bouton rond rose pâle : demande quoi ajouter (souvenir ou date importante)
// puis ouvre le formulaire. Part du coin bas-gauche, se déplace au doigt et
// se colle au bord le plus proche (position partagée par
// FloatingButtonsViewModel). À placer dans un Stack plein écran.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../navigation/add_entry_flow.dart';
import '../viewmodels/floating_buttons_viewmodel.dart';
import 'snapping_button_positioner.dart';

class FloatingAddButton extends StatelessWidget {
  const FloatingAddButton({super.key});

  static const FloatingButtonId _id = FloatingButtonId.add;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FloatingButtonsViewModel>();

    // --- Calque plein écran sans fond : il laisse passer les taps ---
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final area = constraints.biggest;

          return Stack(
            children: [
              SnappingButtonPositioner(
                center: viewModel.centerOf(_id, area),
                isDragging: viewModel.isDragging(_id),
                onDragUpdate: (delta) => viewModel.drag(_id, delta, area),
                onDragEnd: () => viewModel.endDrag(_id, area),
                child: _buildButton(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Material(
      color: primaryContainerLight,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        onTap: () => openAddEntryFlow(context),
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Tooltip(
            message: 'Ajouter',
            child: Icon(Icons.add, color: amorDarkRose, size: 28),
          ),
        ),
      ),
    );
  }
}
