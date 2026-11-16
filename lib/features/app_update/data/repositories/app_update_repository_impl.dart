// ============================================================================
// APP UPDATE REPOSITORY (implémentation)
// ============================================================================
// Assemble la version installée (téléphone) et les releases (GitHub).
// L'extension du fichier à télécharger (".apk" ou ".ipa") est choisie à
// l'assemblage des dépendances, selon la plateforme.

import '../../domain/entities/app_release.dart';
import '../../domain/entities/app_version.dart';
import '../../domain/repositories/app_update_repository.dart';
import '../datasources/app_version_local_datasource.dart';
import '../datasources/github_release_remote_datasource.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  final AppVersionLocalDataSource _localDataSource;
  final GithubReleaseRemoteDataSource _remoteDataSource;
  final String _downloadExtension;

  const AppUpdateRepositoryImpl({
    required AppVersionLocalDataSource localDataSource,
    required GithubReleaseRemoteDataSource remoteDataSource,
    required String downloadExtension,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _downloadExtension = downloadExtension;

  @override
  Future<AppVersion?> getInstalledVersion() async {
    try {
      return AppVersion.tryParse(await _localDataSource.installedVersion());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AppRelease>> getPublishedReleases() async {
    final models = await _remoteDataSource.fetchReleases();
    return models
        .map((model) => model.toEntity(downloadExtension: _downloadExtension))
        .whereType<AppRelease>()
        .toList();
  }
}
