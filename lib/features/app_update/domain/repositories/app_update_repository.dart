// ============================================================================
// APP UPDATE REPOSITORY (contrat)
// ============================================================================
// Version installée sur le téléphone et versions publiées sur GitHub.

import '../entities/app_release.dart';
import '../entities/app_version.dart';

abstract class AppUpdateRepository {
  // --- Null si la version installée est illisible ---
  Future<AppVersion?> getInstalledVersion();

  // --- Releases publiées (hors brouillons). Liste vide si GitHub ne
  // --- répond pas : pas de réseau, quota dépassé... ---
  Future<List<AppRelease>> getPublishedReleases();
}
