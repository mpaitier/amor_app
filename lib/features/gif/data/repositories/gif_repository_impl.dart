// ============================================================================
// GIF REPOSITORY (IMPLEMENTATION)
// ============================================================================

import '../../domain/repositories/gif_repository.dart';
import '../datasources/gif_remote_datasource.dart';

class GifRepositoryImpl implements GifRepository {
  final GifRemoteDataSource _remoteDataSource;

  const GifRepositoryImpl({required GifRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<String?> getRandomGifUrl(String searchTerm) {
    return _remoteDataSource.fetchRandomGifUrl(searchTerm);
  }
}