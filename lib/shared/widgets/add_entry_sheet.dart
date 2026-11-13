// ============================================================================
// ADD ENTRY SHEET
// ============================================================================
// Panneau ouvert par le bouton + : on choisit d'ajouter un souvenir ou une
// date importante. Se ferme en renvoyant le choix. Composant "bête" : il ne
// connaît ni GoRouter ni les écrans d'ajout.

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AddEntryChoice { memory, importantDate }

class AddEntrySheet extends StatelessWidget {
  const AddEntrySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 8),
            _buildChoice(
              context,
              choice: AddEntryChoice.memory,
              icon: Icons.favorite,
              title: 'Un souvenir',
              subtitle: 'Un moment passé, avec ses photos',
            ),
            _buildChoice(
              context,
              choice: AddEntryChoice.importantDate,
              icon: Icons.event,
              title: 'Une date importante',
              subtitle: 'Un jour à ne pas oublier, passé ou à venir',
            ),
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

  Widget _buildChoice(
    BuildContext context, {
    required AddEntryChoice choice,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: amorDarkRose),
      title: Text(
        title,
        style: const TextStyle(
          color: amorDarkRose,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: () => Navigator.of(context).pop(choice),
    );
  }
}
