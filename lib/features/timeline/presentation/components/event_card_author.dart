// ============================================================================
// EVENT CARD AUTHOR
// ============================================================================
// "par Lulu" sous le titre d'une carte de la liste, le surnom dans la
// couleur de la personne. Comme le badge du détail, il lit le profil dans
// le CoupleSessionViewModel et suit donc les changements en temps réel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../couple/domain/entities/couple_member.dart';
import '../../../couple/presentation/components/member_name_text.dart';
import '../../../couple/presentation/models/member_display.dart';
import '../../../couple/presentation/viewmodels/couple_session_viewmodel.dart';

class EventCardAuthor extends StatelessWidget {
  final String creatorUid;

  const EventCardAuthor({super.key, required this.creatorUid});

  @override
  Widget build(BuildContext context) {
    final member = context.select<CoupleSessionViewModel, CoupleMember?>(
      (session) => session.couple?.memberById(creatorUid),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MemberNameText(
        display: MemberDisplay.of(member),
        prefix: 'par ',
        fontSize: 13,
        maxLines: 1,
      ),
    );
  }
}
