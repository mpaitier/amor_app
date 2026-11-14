// ============================================================================
// COUPLE MEMBER TILE
// ============================================================================
// Une ligne de la liste des membres : pastille de couleur et surnom.
// Composant "bête".

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/couple_member.dart';

class CoupleMemberTile extends StatelessWidget {
  final CoupleMember member;
  final bool isMe;

  const CoupleMemberTile({
    super.key,
    required this.member,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final nickname = member.nickname.isEmpty ? 'Sans surnom' : member.nickname;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(member.color),
              shape: BoxShape.circle,
              border: Border.all(color: outlineVariantLight),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMe ? '$nickname (toi)' : nickname,
              style: const TextStyle(fontSize: 16, color: onSurfaceLight),
            ),
          ),
        ],
      ),
    );
  }
}
