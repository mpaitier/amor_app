// ============================================================================
// SETTINGS NOTIFICATIONS TAB
// ============================================================================
// Onglet "Notifications" : les préférences propres à ce téléphone.

import 'package:flutter/material.dart';
import '../../../notifications/presentation/components/notification_preferences_card.dart';
import 'settings_section.dart';
import 'settings_tab_page.dart';

class SettingsNotificationsTab extends StatelessWidget {
  const SettingsNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsTabPage(
      sections: [
        SettingsSection(
          title: 'Sur ce téléphone',
          child: NotificationPreferencesCard(),
        ),
      ],
    );
  }
}
