// ============================================================================
// SETTINGS RELATIONSHIP TAB
// ============================================================================
// Onglet "Relation" : le jour où l'histoire a commencé, les membres et
// l'invitation, puis l'arrêt de la relation.

import 'package:flutter/material.dart';
import '../../../couple/presentation/components/couple_overview_card.dart';
import '../../../couple/presentation/components/end_relationship_card.dart';
import 'relationship_start_field.dart';
import 'settings_section.dart';
import 'settings_tab_page.dart';

class SettingsRelationshipTab extends StatelessWidget {
  const SettingsRelationshipTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsTabPage(
      sections: [
        SettingsSection(
          title: 'Notre histoire a commencé le',
          child: RelationshipStartField(),
        ),
        SettingsSection(
          title: 'Notre relation',
          child: CoupleOverviewCard(),
        ),
        SettingsSection(
          title: 'Arrêter la relation',
          child: EndRelationshipCard(),
        ),
      ],
    );
  }
}
