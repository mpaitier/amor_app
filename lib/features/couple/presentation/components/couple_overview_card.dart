// ============================================================================
// COUPLE OVERVIEW CARD
// ============================================================================
// Bloc "Notre relation" des paramètres : les membres, puis l'invitation.
// Lit le CoupleSessionViewModel global.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/couple_session_viewmodel.dart';
import 'couple_member_tile.dart';
import 'invite_card.dart';

class CoupleOverviewCard extends StatelessWidget {
  const CoupleOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<CoupleSessionViewModel>();
    final couple = session.couple;
    if (couple == null) return const SizedBox.shrink();
    final myUid = session.user?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final member in couple.members)
          CoupleMemberTile(member: member, isMe: member.uid == myUid),
        const Divider(height: 24),
        InviteCard(inviteCode: couple.inviteCode),
      ],
    );
  }
}
