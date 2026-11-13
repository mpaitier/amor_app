// ============================================================================
// IMPORTANT DATE COLOR ROW
// ============================================================================
// Un intitulé, puis une rangée de pastilles qui défile à l'horizontale :
// les couleurs proposées, puis les couleurs libres récentes de ce téléphone
// pour cet usage (un appui long en retire une), et enfin la pastille qui
// ouvre le sélecteur de couleur.
// Sert aussi bien à la bordure qu'au fond, selon la liste, l'usage et le
// callback reçus. Lit l'historique dans le RecentColorsViewModel fourni
// par l'écran.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cream_label.dart';
import '../../../color_history/domain/entities/color_history_kind.dart';
import '../../../color_history/presentation/screens/custom_color_picker.dart';
import '../../../color_history/presentation/viewmodels/recent_colors_viewmodel.dart';
import 'delete_recent_color_dialog.dart';
import 'important_date_color_swatch.dart';

class ImportantDateColorRow extends StatelessWidget {
  final String label;
  final List<int> colors;
  final ColorHistoryKind historyKind;
  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  const ImportantDateColorRow({
    super.key,
    required this.label,
    required this.colors,
    required this.historyKind,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final recentViewModel = context.watch<RecentColorsViewModel>();
    final recentColors = [
      for (final color in recentViewModel.colorsFor(historyKind))
        if (!colors.contains(color)) color,
    ];

    // --- Une couleur retenue absente des deux listes reste visible, mais
    // --- elle n'est pas dans l'historique : rien à y retirer ---
    final isSelectedElsewhere =
        colors.contains(selectedColor) || recentColors.contains(selectedColor);

    final items = <Widget>[
      for (final color in colors) _buildSwatch(color),
      if (recentColors.isNotEmpty || !isSelectedElsewhere) _buildSeparator(),
      if (!isSelectedElsewhere) _buildSwatch(selectedColor),
      for (final color in recentColors)
        _buildSwatch(
          color,
          onLongPress: () => _confirmRemoval(context, recentViewModel, color),
        ),
      _buildCustomButton(context, recentViewModel),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreamLabel(
          text: label,
          style: const TextStyle(
            color: amorDarkRose,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),

        // --- Hauteur fixe : une liste horizontale en a besoin dans un
        // --- formulaire qui défile à la verticale ---
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }

  Widget _buildSwatch(int color, {VoidCallback? onLongPress}) {
    return ImportantDateColorSwatch(
      color: color,
      isSelected: color == selectedColor,
      onTap: () => onColorSelected(color),
      onLongPress: onLongPress,
    );
  }

  // --- Appui long sur une couleur récente : confirmation, puis retrait ---
  Future<void> _confirmRemoval(
    BuildContext context,
    RecentColorsViewModel recentViewModel,
    int color,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteRecentColorDialog(color: color),
    );
    if (confirmed == true) {
      await recentViewModel.removeColor(historyKind, color);
    }
  }

  // --- Sépare les couleurs proposées des couleurs récentes ---
  Widget _buildSeparator() {
    return const Center(
      child: SizedBox(
        height: 28,
        child: VerticalDivider(width: 2, thickness: 1, color: outlineLight),
      ),
    );
  }

  // --- Pastille arc-en-ciel : ouvre le sélecteur de couleur libre ---
  Widget _buildCustomButton(
    BuildContext context,
    RecentColorsViewModel recentViewModel,
  ) {
    return Tooltip(
      message: 'Autre couleur',
      child: InkWell(
        onTap: () => _pickCustomColor(context, recentViewModel),
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  for (var step = 0; step <= 6; step++)
                    HSVColor.fromAHSV(1, step * 60.0, 0.8, 1).toColor(),
                ],
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomColor(
    BuildContext context,
    RecentColorsViewModel recentViewModel,
  ) async {
    final color = await showCustomColorPicker(
      context,
      initialColor: selectedColor,
      recentColors: recentViewModel.colorsFor(historyKind),
    );
    if (color == null) return;

    onColorSelected(color);
    await recentViewModel.addColor(historyKind, color);
  }
}
