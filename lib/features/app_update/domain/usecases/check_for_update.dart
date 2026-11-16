// ============================================================================
// USE CASE: CHECK FOR UPDATE
// ============================================================================
// Cherche la plus récente des releases plus récentes que la version
// installée. Règles :
// - une release sans fichier pour cette plateforme est ignorée (l'.ipa
//   arrive quelques minutes après la création de la release) ;
// - une préversion n'est proposée qu'à qui a déjà une préversion : la
//   version finale, elle, est proposée à tout le monde.

import '../entities/app_release.dart';
import '../entities/app_update.dart';
import '../repositories/app_update_repository.dart';

class CheckForUpdate {
  final AppUpdateRepository _repository;

  const CheckForUpdate(this._repository);

  Future<AppUpdate?> call() async {
    final installed = await _repository.getInstalledVersion();
    if (installed == null) return null;

    AppRelease? newest;
    for (final release in await _repository.getPublishedReleases()) {
      if (!release.hasDownload) continue;
      if (release.version.isPrerelease && !installed.isPrerelease) continue;
      if (!(release.version > installed)) continue;
      if (newest == null || release.version > newest.version) {
        newest = release;
      }
    }

    if (newest == null) return null;
    return AppUpdate(installedVersion: installed, release: newest);
  }
}
