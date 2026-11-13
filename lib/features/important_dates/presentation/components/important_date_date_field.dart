// ============================================================================
// IMPORTANT DATE DATE FIELD
// ============================================================================
// Affiche le jour retenu. Un tap ouvre le sélecteur de date. Composant
// "bête" : ne connaît pas le ViewModel.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class ImportantDateDateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const ImportantDateDateField({
    super.key,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMMM yyyy', 'fr_FR');
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: outlineLight),
    );

    return Material(
      color: Colors.white,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: amorDarkRose, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatter.format(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: onBackgroundLight,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
