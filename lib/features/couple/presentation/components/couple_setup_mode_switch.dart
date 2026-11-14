// ============================================================================
// COUPLE SETUP MODE SWITCH
// ============================================================================
// Choix entre créer une relation et en rejoindre une. Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/couple_setup_viewmodel.dart';

class CoupleSetupModeSwitch extends StatelessWidget {
  final CoupleSetupMode mode;
  final bool enabled;
  final ValueChanged<CoupleSetupMode> onModeChanged;

  const CoupleSetupModeSwitch({
    super.key,
    required this.mode,
    required this.onModeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CoupleSetupMode>(
      segments: const [
        ButtonSegment(
          value: CoupleSetupMode.create,
          icon: Icon(Icons.favorite_border),
          label: Text('Créer'),
        ),
        ButtonSegment(
          value: CoupleSetupMode.join,
          icon: Icon(Icons.group_add_outlined),
          label: Text('Rejoindre'),
        ),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged:
          enabled ? (selection) => onModeChanged(selection.first) : null,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: amorDarkRose,
        selectedForegroundColor: Colors.white,
        foregroundColor: amorDarkRose,
        backgroundColor: Colors.white,
      ),
    );
  }
}
