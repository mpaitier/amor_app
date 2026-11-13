// ============================================================================
// FLOATING ADD BUTTON
// ============================================================================
// Bouton rond rose pâle, en bas à gauche : demande quoi ajouter (souvenir ou
// date importante) puis ouvre le formulaire. Remplace le + des barres du
// haut. À placer dans un Stack.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../navigation/add_entry_flow.dart';

class FloatingAddButton extends StatelessWidget {
  const FloatingAddButton({super.key});

  static const double _margin = 16;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _margin,
      bottom: _margin,
      child: Material(
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
      ),
    );
  }
}
