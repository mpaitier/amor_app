// ============================================================================
// COLOR PICKER DIALOG
// ============================================================================
// Choix d'une couleur libre : carré saturation / luminosité, bande de
// teinte, aperçu et couleurs récentes. Se ferme en renvoyant la couleur
// (entier ARGB), ou null si on annule.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/color_picker_viewmodel.dart';
import 'hue_slider.dart';
import 'recent_colors_row.dart';
import 'saturation_value_panel.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ColorPickerViewModel>();
    final color = viewModel.color;

    return AlertDialog(
      title: const Text('Ma couleur'),
      content: SizedBox(
        width: 280,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                child: SaturationValuePanel(
                  hue: color.hue,
                  saturation: color.saturation,
                  value: color.value,
                  onChanged: viewModel.setSaturationValue,
                ),
              ),
              const SizedBox(height: 16),
              HueSlider(hue: color.hue, onChanged: viewModel.setHue),
              const SizedBox(height: 16),
              _buildPreview(viewModel),
              if (viewModel.recentColors.isNotEmpty) ...[
                const SizedBox(height: 16),
                RecentColorsRow(
                  colors: viewModel.recentColors,
                  onColorSelected: viewModel.selectRecentColor,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => _confirm(context, viewModel),
          child: const Text(
            'Choisir',
            style: TextStyle(color: amorDarkRose, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(ColorPickerViewModel viewModel) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(viewModel.colorValue),
            border: Border.all(color: outlineVariantLight),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          viewModel.hexLabel,
          style: const TextStyle(
            color: onBackgroundLight,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context,
    ColorPickerViewModel viewModel,
  ) async {
    final color = await viewModel.confirm();
    if (context.mounted) Navigator.of(context).pop(color);
  }
}
