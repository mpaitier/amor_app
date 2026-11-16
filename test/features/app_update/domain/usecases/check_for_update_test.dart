// ============================================================================
// TEST UNITAIRE : CheckForUpdate (use case)
// ============================================================================
// Choix de la release à proposer selon la version installée.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/app_update/domain/entities/app_release.dart';
import 'package:amor_app/features/app_update/domain/entities/app_version.dart';
import 'package:amor_app/features/app_update/domain/repositories/app_update_repository.dart';
import 'package:amor_app/features/app_update/domain/usecases/check_for_update.dart';

class MockAppUpdateRepository extends Mock implements AppUpdateRepository {}

AppRelease release(String tag, {bool withFile = true}) {
  return AppRelease(
    version: AppVersion.tryParse(tag)!,
    pageUrl: 'https://github.com/mpaitier/amor_app/releases/tag/$tag',
    downloadUrl: withFile ? 'https://github.com/download/$tag.apk' : null,
  );
}

void main() {
  late MockAppUpdateRepository repository;
  late CheckForUpdate useCase;

  setUp(() {
    repository = MockAppUpdateRepository();
    useCase = CheckForUpdate(repository);
  });

  void givenInstalled(String? version) {
    when(() => repository.getInstalledVersion()).thenAnswer(
      (_) async => version == null ? null : AppVersion.tryParse(version),
    );
  }

  void givenReleases(List<AppRelease> releases) {
    when(() => repository.getPublishedReleases())
        .thenAnswer((_) async => releases);
  }

  test('doit proposer la release la plus récente', () async {
    givenInstalled('1.0.0');
    givenReleases([release('v1.0.1'), release('v1.2.0'), release('v1.1.0')]);

    final update = await useCase();

    expect(update?.release.version, AppVersion.tryParse('1.2.0'));
    expect(update?.installedVersion, AppVersion.tryParse('1.0.0'));
  });

  test('ne doit rien proposer quand l\'app est à jour', () async {
    givenInstalled('1.2.0');
    givenReleases([release('v1.2.0'), release('v1.1.0')]);

    expect(await useCase(), isNull);
  });

  test('ne doit pas proposer de préversion à une version finale', () async {
    givenInstalled('1.0.0');
    givenReleases([release('v1.1.0-beta.1')]);

    expect(await useCase(), isNull);
  });

  test('doit proposer une préversion à qui a déjà une préversion', () async {
    givenInstalled('1.0.0-beta.1');
    givenReleases([release('v1.0.0-beta.2')]);

    final update = await useCase();

    expect(update?.release.version, AppVersion.tryParse('1.0.0-beta.2'));
  });

  test('doit proposer la version finale à qui a une préversion', () async {
    givenInstalled('1.0.0-beta.2');
    givenReleases([release('v1.0.0'), release('v1.0.0-beta.3')]);

    final update = await useCase();

    expect(update?.release.version, AppVersion.tryParse('1.0.0'));
  });

  test('doit ignorer une release sans fichier pour la plateforme', () async {
    givenInstalled('1.0.0');
    givenReleases([release('v1.1.0', withFile: false), release('v1.0.1')]);

    final update = await useCase();

    expect(update?.release.version, AppVersion.tryParse('1.0.1'));
  });

  test('ne doit rien proposer si la version installée est illisible',
      () async {
    givenInstalled(null);
    givenReleases([release('v9.0.0')]);

    expect(await useCase(), isNull);
    verifyNever(() => repository.getPublishedReleases());
  });

  test('ne doit rien proposer sans release publiée', () async {
    givenInstalled('1.0.0');
    givenReleases([]);

    expect(await useCase(), isNull);
  });
}
