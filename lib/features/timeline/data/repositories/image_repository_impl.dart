// ============================================================================
// IMAGE REPOSITORY (IMPLEMENTATION)
// ============================================================================
// Combines the local (pick) and remote (upload) data sources behind
// the single ImageRepository contract expected by the domain layer.

import 'dart:io';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_local_datasource.dart';
import '../datasources/image_remote_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageLocalDataSource _localDataSource;
  final ImageRemoteDataSource _remoteDataSource;

  const ImageRepositoryImpl({
    required ImageLocalDataSource localDataSource,
    required ImageRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<List<File>> pickMultipleFromGallery() {
    return _localDataSource.pickMultipleFromGallery();
  }

  @override
  Future<File?> takePhoto() {
    return _localDataSource.takePhoto();
  }

  @override
  Future<String?> uploadImage({
    required File imageFile,
    required String folder,
  }) {
    return _remoteDataSource.uploadImage(imageFile: imageFile, folder: folder);
  }

  @override
  Future<List<String>> uploadImages({
    required List<File> imageFiles,
    required String folder,
  }) {
    return _remoteDataSource.uploadImages(
      imageFiles: imageFiles,
      folder: folder,
    );
  }

  @override
  Future<void> deleteImage(String imageUrl) {
    return _remoteDataSource.deleteImage(imageUrl);
  }
}