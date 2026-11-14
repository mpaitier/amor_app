// ============================================================================
// SETTINGS TAB PAGE
// ============================================================================
// Une page d'onglet : ses sections les unes sous les autres, avec la marge
// du bas qui dégage le menu flottant. La page reste en mémoire quand on
// glisse vers une autre : en revenant, on la retrouve au même endroit.

import 'package:flutter/material.dart';

class SettingsTabPage extends StatefulWidget {
  final List<Widget> sections;

  const SettingsTabPage({super.key, required this.sections});

  @override
  State<SettingsTabPage> createState() => _SettingsTabPageState();
}

class _SettingsTabPageState extends State<SettingsTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: widget.sections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) => widget.sections[index],
    );
  }
}
