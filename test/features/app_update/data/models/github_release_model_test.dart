// ============================================================================
// TEST UNITAIRE : GithubReleaseModel
// ============================================================================
// Lecture d'une release de l'API GitHub et choix du fichier par plateforme.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/app_update/data/models/github_release_model.dart';
import 'package:amor_app/features/app_update/domain/entities/app_version.dart';

Map<String, dynamic> releaseJson({
  String tag = 'v1.0.0-beta.2',
  bool draft = false,
  List<String> assetNames = const [
    'amor-1.0.0-beta.2.aab',
    'amor-1.0.0-beta.2.apk',
    'amor-1.0.0-beta.2.ipa',
  ],
}) {
  return {
    'tag_name': tag,
    'html_url': 'https://github.com/mpaitier/amor_app/releases/tag/$tag',
    'draft': draft,
    'prerelease': tag.contains('-'),
    'assets': [
      for (final name in assetNames)
        {
          'name': name,
          'browser_download_url':
              'https://github.com/mpaitier/amor_app/releases/download/$tag/$name',
        },
    ],
  };
}

void main() {
  test('doit lire la version, la page et le fichier .apk', () {
    final release = GithubReleaseModel.fromJson(releaseJson())
        .toEntity(downloadExtension: '.apk');

    expect(release?.version, AppVersion.tryParse('1.0.0-beta.2'));
    expect(
      release?.pageUrl,
      'https://github.com/mpaitier/amor_app/releases/tag/v1.0.0-beta.2',
    );
    expect(release?.downloadUrl, endsWith('/amor-1.0.0-beta.2.apk'));
  });

  test('doit choisir le .ipa pour iOS', () {
    final release = GithubReleaseModel.fromJson(releaseJson())
        .toEntity(downloadExtension: '.ipa');

    expect(release?.downloadUrl, endsWith('/amor-1.0.0-beta.2.ipa'));
  });

  test('doit laisser le fichier vide tant que le .ipa n\'est pas en ligne', () {
    final json = releaseJson(assetNames: ['amor-1.0.0.aab', 'amor-1.0.0.apk']);
    final release =
        GithubReleaseModel.fromJson(json).toEntity(downloadExtension: '.ipa');

    expect(release, isNotNull);
    expect(release!.hasDownload, isFalse);
  });

  test('doit ignorer un brouillon', () {
    final release = GithubReleaseModel.fromJson(releaseJson(draft: true))
        .toEntity(downloadExtension: '.apk');

    expect(release, isNull);
  });

  test('doit ignorer un tag qui n\'est pas une version', () {
    final release = GithubReleaseModel.fromJson(releaseJson(tag: 'nightly'))
        .toEntity(downloadExtension: '.apk');

    expect(release, isNull);
  });

  test('doit tolérer les champs absents', () {
    final model = GithubReleaseModel.fromJson(const {});

    expect(model.tagName, '');
    expect(model.assets, isEmpty);
    expect(model.toEntity(downloadExtension: '.apk'), isNull);
  });
}
