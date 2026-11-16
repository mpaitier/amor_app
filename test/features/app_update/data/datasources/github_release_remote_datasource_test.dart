// ============================================================================
// TEST UNITAIRE : GithubReleaseRemoteDataSource
// ============================================================================
// Appel de l'API GitHub, avec un faux client HTTP.

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amor_app/features/app_update/data/datasources/github_release_remote_datasource.dart';

void main() {
  GithubReleaseRemoteDataSource dataSourceWith(MockClient client) {
    return GithubReleaseRemoteDataSource(
      httpClient: client,
      repository: 'mpaitier/amor_app',
    );
  }

  test('doit appeler la liste des releases du dépôt', () async {
    late Uri calledUri;
    final client = MockClient((request) async {
      calledUri = request.url;
      return http.Response('[]', 200);
    });

    await dataSourceWith(client).fetchReleases();

    expect(calledUri.host, 'api.github.com');
    expect(calledUri.path, '/repos/mpaitier/amor_app/releases');
  });

  test('doit lire les releases renvoyées', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode([
          {
            'tag_name': 'v1.0.0',
            'html_url': 'https://github.com/mpaitier/amor_app/releases/tag/v1.0.0',
            'draft': false,
            'assets': [],
          },
          {
            'tag_name': 'v1.0.0-beta.2',
            'html_url':
                'https://github.com/mpaitier/amor_app/releases/tag/v1.0.0-beta.2',
            'draft': false,
            'assets': [],
          },
        ]),
        200,
      );
    });

    final releases = await dataSourceWith(client).fetchReleases();

    expect(releases.map((r) => r.tagName), ['v1.0.0', 'v1.0.0-beta.2']);
  });

  test('doit renvoyer une liste vide si GitHub refuse', () async {
    final client = MockClient((_) async => http.Response('rate limit', 403));

    expect(await dataSourceWith(client).fetchReleases(), isEmpty);
  });

  test('doit renvoyer une liste vide sans réseau', () async {
    final client = MockClient((_) async => throw http.ClientException('off'));

    expect(await dataSourceWith(client).fetchReleases(), isEmpty);
  });

  test('doit renvoyer une liste vide si la réponse est illisible', () async {
    final client = MockClient((_) async => http.Response('{oops', 200));

    expect(await dataSourceWith(client).fetchReleases(), isEmpty);
  });
}
