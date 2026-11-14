// ============================================================================
// SETTINGS SCREEN
// ============================================================================
// Paramètres répartis en onglets, façon YouTube : on passe de l'un à
// l'autre en touchant son nom ou en glissant la page, et le trait sous
// l'onglet suit le geste.
// - Relation : début de l'histoire, membres et invitation, arrêt
// - Calendrier : anniversaires, mois-anniversaires, GIF
// - Notifications : préférences de ce téléphone
// - Compte : profil, déconnexion, inactivité, suppression
// Chaque changement est enregistré aussitôt. Les ViewModels sont fournis
// au-dessus des onglets : leur état survit au passage d'un onglet à l'autre.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../../../auth/presentation/viewmodels/account_viewmodel.dart';
import '../../../color_history/presentation/viewmodels/recent_colors_viewmodel.dart';
import '../../../couple/presentation/viewmodels/couple_end_viewmodel.dart';
import '../../../couple/presentation/viewmodels/couple_session_viewmodel.dart';
import '../../../couple/presentation/viewmodels/member_profile_viewmodel.dart';
import '../../../navigation/presentation/components/floating_nav_menu.dart';
import '../../../notifications/presentation/viewmodels/notification_preferences_viewmodel.dart';
import '../components/settings_account_tab.dart';
import '../components/settings_calendar_tab.dart';
import '../components/settings_notifications_tab.dart';
import '../components/settings_relationship_tab.dart';
import '../components/settings_tab_bar.dart';
import '../components/settings_top_bar.dart';
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
        // --- Demande d'arrêt de la relation ---
        ChangeNotifierProvider(
          create: (_) => CoupleEndViewModel(
            requestCoupleEnd: sl.requestCoupleEnd,
            respondToCoupleEnd: sl.respondToCoupleEnd,
            cancelCoupleEnd: sl.cancelCoupleEnd,
          ),
        ),
        // --- Suppression du compte ---
        ChangeNotifierProvider(
          create: (_) => AccountViewModel(deleteAccount: sl.deleteAccount),
        ),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  static const List<String> _tabLabels = [
    'Relation',
    'Calendrier',
    'Notifications',
    'Compte',
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final hasProfile = context.read<CoupleSessionViewModel>().me != null;

    return DefaultTabController(
      length: _tabLabels.length,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // --- Stack requis : FloatingNavMenu se positionne via Positioned ---
        body: Stack(
          children: [
            Column(
              children: [
                SettingsTopBar(onBack: () => _goBack(context)),
                const SettingsTabBar(labels: _tabLabels),
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: errorLight),
                    ),
                  ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: amorPink),
                        )
                      : TabBarView(
                          children: [
                            const SettingsRelationshipTab(),
                            const SettingsCalendarTab(),
                            const SettingsNotificationsTab(),
                            SettingsAccountTab(hasProfile: hasProfile),
                          ],
                        ),
                ),
              ],
            ),

            // --- Menu de navigation flottant, bas-droite ---
            const FloatingNavMenu(currentRoute: AppRoutes.settings),
          ],
        ),
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
}
