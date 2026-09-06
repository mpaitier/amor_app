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