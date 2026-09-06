// ============================================================================
// GIF REPOSITORY (INTERFACE)
// ============================================================================

abstract class GifRepository {
  Future<String?> getRandomGifUrl(String searchTerm);
}