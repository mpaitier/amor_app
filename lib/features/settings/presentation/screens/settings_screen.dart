// ============================================================================
// SETTINGS SCREEN
// ============================================================================
// Réglages partagés du couple : la date de début de l'histoire, puis
// l'affichage de l'anniversaire et des mois-anniversaires dans le
// calendrier. Chaque changement est enregistré aussitôt.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../../../color_history/presentation/viewmodels/recent_colors_viewmodel.dart';
import '../../../important_dates/presentation/utils/important_date_labels.dart';
import '../../../navigation/presentation/components/floating_nav_menu.dart';
import '../../domain/utils/anniversary_titles.dart';
import '../components/gif_search_term_field.dart';
import '../components/relationship_start_field.dart';
import '../components/settings_section.dart';
import '../components/settings_top_bar.dart';
import '../components/special_day_setting_card.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(
            watchCoupleSettings: sl.watchCoupleSettings,
            saveCoupleSettings: sl.saveCoupleSettings,
          ),
        ),
        // --- Couleurs libres récentes, lues par les rangées de couleurs ---
        ChangeNotifierProvider(
          create: (_) => RecentColorsViewModel(
            getRecentColors: sl.getRecentColors,
            addRecentColor: sl.addRecentColor,
            removeRecentColor: sl.removeRecentColor,
          ),
        ),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      // --- Stack requis : FloatingNavMenu se positionne via Positioned ---
      body: Stack(
        children: [
          Column(
            children: [
              const SettingsTopBar(),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: amorPink),
                      )
                    : _buildContent(viewModel),
              ),
            ],
          ),

          // --- Menu de navigation flottant, bas-droite ---
          const FloatingNavMenu(currentRoute: AppRoutes.settings),
        ],
      ),
    );
  }

  Widget _buildContent(SettingsViewModel viewModel) {
    final settings = viewModel.settings;
    final today = viewModel.today;

    return ListView(
      // --- Marge du bas pour dégager le menu flottant ---
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (viewModel.errorMessage != null) ...[
          Text(
            viewModel.errorMessage!,
            style: const TextStyle(color: errorLight),
          ),
          const SizedBox(height: 12),
        ],
        const SettingsSection(
          title: 'Notre histoire a commencé le',
          child: RelationshipStartField(),
        ),
        const SizedBox(height: 20),
        SettingsSection(
          title: 'Calendrier',
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SettingsSection(
          title: 'GIF des souvenirs et des dates',
          child: GifSearchTermField(),
        ),
      ],
    );
  }
}
