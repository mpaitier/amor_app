// ============================================================================
// GITHUB RELEASE MODEL
// ============================================================================
// Une release telle que la renvoie l'API GitHub
// (GET /repos/{owner}/{repo}/releases), réduite à ce dont l'app a besoin.

import '../../domain/entities/app_release.dart';
import '../../domain/entities/app_version.dart';

class GithubReleaseAsset {
  final String name;
  final String downloadUrl;

  const GithubReleaseAsset({required this.name, required this.downloadUrl});

  factory GithubReleaseAsset.fromJson(Map<String, dynamic> json) {
    return GithubReleaseAsset(
      name: json['name'] as String? ?? '',
      downloadUrl: json['browser_download_url'] as String? ?? '',
    );
  }
}

class GithubReleaseModel {
  final String tagName;
  final String htmlUrl;
  final bool isDraft;
  final List<GithubReleaseAsset> assets;

  const GithubReleaseModel({
    required this.tagName,
    required this.htmlUrl,
    required this.isDraft,
    required this.assets,
  });

  factory GithubReleaseModel.fromJson(Map<String, dynamic> json) {
    final assets = json['assets'] as List<dynamic>? ?? const [];
    return GithubReleaseModel(
      tagName: json['tag_name'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      isDraft: json['draft'] as bool? ?? false,
      assets: [
        for (final asset in assets)
          GithubReleaseAsset.fromJson(asset as Map<String, dynamic>),
      ],
    );
  }

  // --- Null pour un brouillon ou un tag qui n'est pas une version. Le
  // --- fichier retenu est le premier dont le nom finit par l'extension de
  // --- la plateforme (".apk" ou ".ipa") ---
  AppRelease? toEntity({required String downloadExtension}) {
    if (isDraft) return null;
    final version = AppVersion.tryParse(tagName);
    if (version == null) return null;

    String? downloadUrl;
    for (final asset in assets) {
      final matches = asset.name.toLowerCase().endsWith(downloadExtension);
      if (matches && asset.downloadUrl.isNotEmpty) {
        downloadUrl = asset.downloadUrl;
        break;
      }
    }

    return AppRelease(
      version: version,
      pageUrl: htmlUrl,
      downloadUrl: downloadUrl,
    );
  }
}
