// ============================================================================
// CURRENT COUPLE
// ============================================================================
// Identifiant de la relation de la personne connectée, partagé avec les data
// sources qui rangent leurs données sous couples/{coupleId}/. Mis à jour par
// la session (main.dart) à chaque connexion, déconnexion ou changement de
// relation. Les écrans qui lisent ces données ne sont accessibles qu'avec
// une relation : l'identifiant est donc connu quand elles s'en servent.

class NoCurrentCoupleException implements Exception {
  const NoCurrentCoupleException();

  @override
  String toString() => 'NoCurrentCoupleException: aucune relation active';
}

class CurrentCouple {
  String? _id;

  String? get idOrNull => _id;

  // --- Lève une exception si aucune relation n'est active ---
  String get id {
    final value = _id;
    if (value == null || value.isEmpty) throw const NoCurrentCoupleException();
    return value;
  }

  void set(String? id) => _id = id;

  // --- Chemin d'un document ou d'une collection de la relation ---
  String path(String relativePath) => 'couples/$id/$relativePath';
}
