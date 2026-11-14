// ============================================================================
// APP USER (ENTITY)
// ============================================================================
// La personne connectée, telle que le reste de l'app la voit. Ne dépend
// d'aucun package Firebase.

class AppUser {
  final String uid;
  final String email;
  final String displayName;

  const AppUser({
    required this.uid,
    this.email = '',
    this.displayName = '',
  });

  @override
  bool operator ==(Object other) {
    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => Object.hash(uid, email, displayName);
}
