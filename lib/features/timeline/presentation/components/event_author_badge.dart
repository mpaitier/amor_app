// ============================================================================
// EVENT AUTHOR BADGE
// ============================================================================
// "Créé par Titi" dans le détail d'un souvenir : la pastille et le surnom
// dans la couleur de la personne. Le profil est lu dans le
// CoupleSessionViewModel, suivi en temps réel : un changement de surnom ou
// de couleur dans les paramètres s'affiche aussitôt.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../couple/domain/entities/couple_member.dart';
import '../../../couple/presentation/components/member_name_text.dart';
import '../../../couple/presentation/models/member_display.dart';
import '../../../couple/presentation/viewmodels/couple_session_viewmodel.dart';

class EventAuthorBadge extends StatelessWidget {
  final String creatorUid;

  const EventAuthorBadge({super.key, required this.creatorUid});

  @override
  Widget build(BuildContext context) {
    final member = context.select<CoupleSessionViewModel, CoupleMember?>(
      (session) => session.couple?.memberById(creatorUid),
    );
    final display = MemberDisplay.of(member);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: amorCreamTransparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: display.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MemberNameText(display: display, prefix: 'Créé par '),
          ),
        ],
      ),
    );
  }
}
