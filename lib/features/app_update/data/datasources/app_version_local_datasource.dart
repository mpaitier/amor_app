// ============================================================================
// APP VERSION LOCAL DATA SOURCE
// ============================================================================
// Version installée sur le téléphone. Les builds du workflow de release
// reçoivent le numéro exact du tag par --dart-define=APP_VERSION=...
// Sans lui (build locale), on lit la version du paquet installé. Sur iOS,
// celle-ci perd sa préversion (1.0.0-beta.2 devient 1.0.0), d'où la
// priorité au --dart-define.

import 'package:package_info_plus/package_info_plus.dart';

class AppVersionLocalDataSource {
  static const String _buildVersion = String.fromEnvironment('APP_VERSION');

  const AppVersionLocalDataSource();

  Future<String> installedVersion() async {
    if (_buildVersion.isNotEmpty) return _buildVersion;
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}
