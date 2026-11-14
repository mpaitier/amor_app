// ============================================================================
// EVENT AUTHOR BADGE
// ============================================================================
// "Créé par Titi", avec la pastille de couleur de la personne. Le surnom
// vient de son profil dans la relation, lu dans le CoupleSessionViewModel :
// il suit donc les changements faits dans les paramètres.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../couple/domain/entities/couple_member.dart';
import '../../../couple/presentation/viewmodels/couple_session_viewmodel.dart';

class EventAuthorBadge extends StatelessWidget {
  final String creatorUid;

  const EventAuthorBadge({super.key, required this.creatorUid});

  @override
  Widget build(BuildContext context) {
    final member = context.select<CoupleSessionViewModel, CoupleMember?>(
      (session) => session.couple?.memberById(creatorUid),
    );

    // --- Membre parti ou souvenir sans auteur connu ---
    final label = member == null
        ? 'Créé par un ancien membre'
        : 'Créé par ${member.nickname}';
    final color = member == null ? outlineLight : Color(member.color);

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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF616161),
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
