// ============================================================================
// SPECIAL DAY SETTING CARD
// ============================================================================
// Réglage d'un jour spécial (anniversaire ou mois-anniversaire) : un
// interrupteur pour l'afficher dans le calendrier, puis, s'il est activé,
// l'aperçu du prochain et le choix de son style. Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../important_dates/presentation/components/important_date_banner.dart';
import '../../domain/entities/special_day_style.dart';
import 'special_day_style_editor.dart';

class SpecialDaySettingCard extends StatelessWidget {
  final String label;
  final String description;
  final bool isShown;
  final ValueChanged<bool> onShownChanged;
  final SpecialDayStyle style;
  final ValueChanged<SpecialDayStyle> onStyleChanged;
  final String previewTitle;
  final String previewCountdown;

  const SpecialDaySettingCard({
    super.key,
    required this.label,
    required this.description,
    required this.isShown,
    required this.onShownChanged,
    required this.style,
    required this.onStyleChanged,
    required this.previewTitle,
    required this.previewCountdown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: onBackgroundLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(color: outlineLight, fontSize: 13),
                  ),
                ],
              ),
            ),
            Switch(value: isShown, onChanged: onShownChanged),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: isShown
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ImportantDateBanner(
                        emoji: style.emoji,
                        title: previewTitle,
                        countdown: previewCountdown,
                        backgroundColor: style.backgroundColor,
                        borderColor: style.borderColor,
                      ),
                      const SizedBox(height: 12),
                      SpecialDayStyleEditor(
                        style: style,
                        onChanged: onStyleChanged,
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
