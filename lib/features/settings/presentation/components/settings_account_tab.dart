// ============================================================================
// SETTINGS ACCOUNT TAB
// ============================================================================
// Onglet "Compte" : surnom et couleur de la personne connectée, puis le
// compte (déconnexion, règle d'inactivité, suppression).

import 'package:flutter/material.dart';
import '../../../auth/presentation/components/account_card.dart';
import '../../../couple/presentation/components/member_profile_editor.dart';
import 'settings_section.dart';
import 'settings_tab_page.dart';

class SettingsAccountTab extends StatelessWidget {
  // --- Le profil n'est modifiable que si la personne est membre ---
  final bool hasProfile;

  const SettingsAccountTab({super.key, required this.hasProfile});

  @override
  Widget build(BuildContext context) {
    return SettingsTabPage(
      sections: [
        if (hasProfile)
          const SettingsSection(
            title: 'Mon profil',
            child: MemberProfileEditor(),
          ),
        const SettingsSection(
          title: 'Compte',
          child: AccountCard(),
        ),
      ],
    );
  }
}
