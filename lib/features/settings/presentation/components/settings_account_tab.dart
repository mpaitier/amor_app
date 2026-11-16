// ============================================================================
// SETTINGS ACCOUNT TAB
// ============================================================================
// Onglet "Compte" : surnom et couleur de la personne connectée, le compte
// (déconnexion, règle d'inactivité, suppression), puis la politique de
// confidentialité.

import 'package:flutter/material.dart';
import '../../../auth/presentation/components/account_card.dart';
import '../../../couple/presentation/components/member_profile_editor.dart';
import 'privacy_policy_tile.dart';
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
        const SettingsSection(
          title: 'Confidentialité',
          child: PrivacyPolicyTile(),
        ),
      ],
    );
  }
}
