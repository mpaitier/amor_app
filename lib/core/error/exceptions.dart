// ============================================================================
// CUSTOM EXCEPTIONS
// ============================================================================
// Data-level exceptions thrown by data sources and caught by repositories
// or view models further up the call chain.

class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'A server error occurred']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'A local storage error occurred']);

  @override
  String toString() => message;
}

class ImageUploadException implements Exception {
  final String message;
  const ImageUploadException([this.message = 'Image upload failed']);

  @override
  String toString() => message;
}

class ImagePickException implements Exception {
  final String message;
  const ImagePickException([this.message = 'Image selection failed']);

  @override
  String toString() => message;
}

// --- Échec remonté par Firebase Auth ou Google Sign-In. Porte le code
// --- brut ("wrong-password", "network-request-failed"...), traduit plus
// --- haut par le repository ---
class AuthException implements Exception {
  final String code;
  const AuthException(this.code);

  @override
  String toString() => 'AuthException($code)';
}

// --- Échec remonté par une Cloud Function ou par Firestore lors d'une
// --- opération sur la relation. Porte le code brut ("not-found",
// --- "already-exists"...), traduit plus haut par le repository ---
class CoupleException implements Exception {
  final String code;
  const CoupleException(this.code);

  @override
  String toString() => 'CoupleException($code)';
}
