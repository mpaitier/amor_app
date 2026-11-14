// ============================================================================
// COUPLE START DATE FIELD
// ============================================================================
// Jour où l'histoire a commencé, demandé à la création de la relation.
// Affiche une invite tant qu'aucune date n'est choisie. Composant "bête" :
// le sélecteur de date est ouvert par celui qui l'utilise.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class CoupleStartDateField extends StatelessWidget {
  final DateTime? date;
  final bool enabled;
  final VoidCallback onTap;

  const CoupleStartDateField({
    super.key,
    required this.date,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMMM yyyy', 'fr_FR');
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: outlineLight),
    );
    final hasDate = date != null;

    return Material(
      color: Colors.white,
      shape: shape,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: shape,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.favorite_outline, color: amorDarkRose, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasDate ? formatter.format(date!) : 'Choisir le jour',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasDate ? onBackgroundLight : outlineLight,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month, color: outlineLight, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
