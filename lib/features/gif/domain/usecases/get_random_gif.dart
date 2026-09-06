// ============================================================================
// USE CASE: GET RANDOM GIF
// ============================================================================

import '../repositories/gif_repository.dart';

class GetRandomGif {
  final GifRepository _repository;
  const GetRandomGif(this._repository);

  Future<String?> call(String searchTerm) {
    return _repository.getRandomGifUrl(searchTerm);
  }
}