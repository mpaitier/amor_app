// ============================================================================
// SETTINGS SCREEN
// ============================================================================
// Réglages partagés du couple : la date de début de l'histoire, puis
// l'affichage de l'anniversaire et des mois-anniversaires dans le
// calendrier. Chaque changement est enregistré aussitôt. Viennent ensuite
// la relation (membres, invitation), le profil de la personne connectée,
// et enfin le compte avec la déconnexion.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../../../auth/presentation/components/account_card.dart';
import '../../../couple/presentation/components/couple_overview_card.dart';
import '../../../couple/presentation/components/member_profile_editor.dart';
import '../../../couple/presentation/viewmodels/couple_session_viewmodel.dart';
import '../../../couple/presentation/viewmodels/member_profile_viewmodel.dart';
import '../../../color_history/presentation/viewmodels/recent_colors_viewmodel.dart';
import '../../../notifications/presentation/components/notification_preferences_card.dart';
import '../../../notifications/presentation/viewmodels/notification_preferences_viewmodel.dart';
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
    // --- L'écran n'est accessible qu'avec une relation : me et coupleId
    // --- sont donc connus ---
    final session = context.read<CoupleSessionViewModel>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(
            watchCoupleSettings: sl.watchCoupleSettings,
            saveCoupleSettings: sl.saveCoupleSettings,
            getRandomGif: sl.getRandomGif,
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
        // --- Surnom et couleur de la personne connectée ---
        if (session.me != null && session.coupleId != null)
          ChangeNotifierProvider(
            create: (_) => MemberProfileViewModel(
              updateMemberProfile: sl.updateMemberProfile,
              coupleId: session.coupleId!,
              member: session.me!,
            ),
          ),
        // --- Préférences de notifications, propres à ce téléphone ---
        ChangeNotifierProvider(
          create: (_) => NotificationPreferencesViewModel(
            watchPreferences: sl.watchNotificationPreferences,
            savePreferences: sl.saveNotificationPreferences,
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
    final hasProfile = context.read<CoupleSessionViewModel>().me != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // --- Stack requis : FloatingNavMenu se positionne via Positioned ---
      body: Stack(
        children: [
          Column(
            children: [
              SettingsTopBar(onBack: () => _goBack(context)),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: amorPink),
                      )
                    : _buildContent(viewModel, hasProfile: hasProfile),
              ),
            ],
          ),

          // --- Menu de navigation flottant, bas-droite ---
          const FloatingNavMenu(currentRoute: AppRoutes.settings),
        ],
      ),
    );
  }

  // --- Retour à l'écran d'où l'on vient. Sans écran en dessous (lien
  // --- direct), on rejoint le journal ---
  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.mainMenu);
    }
  }

  Widget _buildContent(
    SettingsViewModel viewModel, {
    required bool hasProfile,
  }) {
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
        const SizedBox(height: 20),
        const SettingsSection(
          title: 'Notifications',
          child: NotificationPreferencesCard(),
        ),
        const SizedBox(height: 20),
        const SettingsSection(
          title: 'GIF des souvenirs et des dates',
          child: GifSearchTermField(),
        ),
        const SizedBox(height: 20),
        const SettingsSection(
          title: 'Notre relation',
          child: CoupleOverviewCard(),
        ),
        if (hasProfile) ...[
          const SizedBox(height: 20),
          const SettingsSection(
            title: 'Mon profil',
            child: MemberProfileEditor(),
          ),
        ],
        const SizedBox(height: 20),
        const SettingsSection(
          title: 'Compte',
          child: AccountCard(),
        ),
      ],
    );
  }
}
