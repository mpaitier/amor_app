// ============================================================================
// IMPORTANT DATE FORM ACTIONS
// ============================================================================
// Boutons du bas du formulaire : annuler et valider. Composant "bête" :
// ne connaît ni le ViewModel ni GoRouter.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ImportantDateFormActions extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const ImportantDateFormActions({
    super.key,
    required this.isSaving,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: _buildButton(
                label: 'Annuler',
                color: outlineLight,
                onPressed: isSaving ? null : onCancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildButton(
                label: isSaving ? 'Enregistrement...' : 'Valider',
                color: amorDarkRose,
                onPressed: isSaving ? null : onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
