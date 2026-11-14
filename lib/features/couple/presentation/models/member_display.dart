// ============================================================================
// MEMBER DISPLAY
// ============================================================================
// Ce qu'on affiche pour l'auteur d'un souvenir : son surnom et sa couleur.
// - membre introuvable (parti, ou souvenir sans auteur) : "un ancien membre",
//   couleur par défaut
// - surnom vide (ancien profil) : "un membre", avec sa couleur
// color sert aux pastilles ; textColor est la même teinte, assombrie si
// besoin pour rester lisible en texte sur fond clair.

import 'package:flutter/painting.dart';
import '../../../../core/theme/readable_text_color.dart';
import '../../domain/entities/couple_member.dart';

class MemberDisplay {
  static const String formerMemberName = 'un ancien membre';
  static const String unnamedMemberName = 'un membre';

  final String name;
  final Color color;

  const MemberDisplay({required this.name, required this.color});

  factory MemberDisplay.of(CoupleMember? member) {
    if (member == null) {
      return const MemberDisplay(
        name: formerMemberName,
        color: Color(CoupleMember.defaultColor),
      );
    }

    final nickname = member.nickname.trim();
    return MemberDisplay(
      name: nickname.isEmpty ? unnamedMemberName : nickname,
      color: Color(member.color),
    );
  }

  Color get textColor => readableTextColor(color);

  @override
  bool operator ==(Object other) {
    return other is MemberDisplay &&
        other.name == name &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(name, color);
}
