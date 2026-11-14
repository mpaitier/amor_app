// ============================================================================
// COUPLE MEMBER (ENTITY)
// ============================================================================
// Une personne de la relation, avec le surnom et la couleur qu'elle a
// choisis. La couleur est un entier ARGB, tel qu'il est enregistré.

class CoupleMember {
  final String uid;
  final String nickname;
  final int color;

  const CoupleMember({
    required this.uid,
    required this.nickname,
    required this.color,
  });

  CoupleMember copyWith({String? nickname, int? color}) {
    return CoupleMember(
      uid: uid,
      nickname: nickname ?? this.nickname,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CoupleMember &&
        other.uid == uid &&
        other.nickname == nickname &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(uid, nickname, color);
}
