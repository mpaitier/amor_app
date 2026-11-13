// ============================================================================
// IMPORTANT DATE FORM SECTION
// ============================================================================
// Bloc du formulaire : un intitulé, puis son contenu sur fond crème.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ImportantDateFormSection extends StatelessWidget {
  final String label;
  final Widget child;

  const ImportantDateFormSection({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // --- Material plutôt que Container : l'effet d'encre des choix se
    // --- dessine ainsi par-dessus le fond crème ---
    return Material(
      color: amorCream,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF616161), fontSize: 14),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
