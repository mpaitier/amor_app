// ============================================================================
// APP UPDATE
// ============================================================================
// Mise à jour disponible : la version installée et la release plus récente
// à proposer.

import 'app_release.dart';
import 'app_version.dart';

class AppUpdate {
  final AppVersion installedVersion;
  final AppRelease release;

  const AppUpdate({required this.installedVersion, required this.release});
}
