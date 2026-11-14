// ============================================================================
// SETTINGS CALENDAR TAB
// ============================================================================
// Onglet "Calendrier" : anniversaire et mois-anniversaires (affichage,
// style, aperçu), puis le terme de recherche des GIF. Branché sur le
// SettingsViewModel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../important_dates/presentation/utils/important_date_labels.dart';
import '../../domain/utils/anniversary_titles.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'gif_search_term_field.dart';
import 'settings_section.dart';
import 'settings_tab_page.dart';
import 'special_day_setting_card.dart';

class SettingsCalendarTab extends StatelessWidget {
  const SettingsCalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final settings = viewModel.settings;
    final today = viewModel.today;

    return SettingsTabPage(
      sections: [
        SettingsSection(
          title: 'Anniversaires',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SpecialDaySettingCard(
                label: 'Anniversaire',
                description: 'Chaque année, le jour où tout a commencé',
                isShown: settings.showAnniversary,
                onShownChanged: viewModel.setShowAnniversary,
                style: settings.anniversaryStyle,
                onStyleChanged: viewModel.setAnniversaryStyle,
                previewTitle: anniversaryTitle(viewModel.nextAnniversaryNumber),
                previewCountdown: formatShortCountdown(
                  viewModel.nextAnniversary,
                  today,
                ),
                isGifLoading: viewModel.isAnniversaryGifLoading,
                onRefreshGif: viewModel.drawAnniversaryGif,
              ),
              const Divider(height: 28),
              SpecialDaySettingCard(
                label: 'Mois-anniversaires',
                description: 'Chaque mois, le même jour que le début',
                isShown: settings.showMonthAnniversaries,
                onShownChanged: viewModel.setShowMonthAnniversaries,
                style: settings.monthAnniversaryStyle,
                onStyleChanged: viewModel.setMonthAnniversaryStyle,
                previewTitle: monthAnniversaryTitle(
                  viewModel.nextMonthAnniversaryNumber,
                ),
                previewCountdown: formatShortCountdown(
                  viewModel.nextMonthAnniversary,
                  today,
                ),
                isGifLoading: viewModel.isMonthAnniversaryGifLoading,
                onRefreshGif: viewModel.drawMonthAnniversaryGif,
              ),
            ],
          ),
        ),
        const SettingsSection(
          title: 'GIF des souvenirs et des dates',
          child: GifSearchTermField(),
        ),
      ],
    );
  }
}
