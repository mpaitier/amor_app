// ============================================================================
// APP RELEASE
// ============================================================================
// Une version publiée dans les releases GitHub, vue depuis le téléphone :
// son numéro, sa page, et le fichier à télécharger pour cette plateforme
// (.apk sur Android, .ipa sur iOS), absent tant qu'il n'est pas en ligne.

import 'app_version.dart';

class AppRelease {
  final AppVersion version;
  final String pageUrl;
  final String? downloadUrl;

  const AppRelease({
    required this.version,
    required this.pageUrl,
    this.downloadUrl,
  });

  bool get hasDownload => downloadUrl != null;
}
