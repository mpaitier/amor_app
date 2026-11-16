// ============================================================================
// GITHUB RELEASE REMOTE DATA SOURCE
// ============================================================================
// Liste des releases publiées sur le dépôt, via l'API publique de GitHub
// (sans authentification : 60 requêtes par heure et par adresse IP, bien
// assez pour une vérification à l'ouverture). Un échec renvoie une liste
// vide et est journalisé dans la console : l'app ne doit jamais bloquer
// parce que GitHub ne répond pas.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/github_release_model.dart';

class GithubReleaseRemoteDataSource {
  final http.Client _httpClient;
  final String _repository;

  static const Duration _timeout = Duration(seconds: 8);

  // --- Les plus récentes d'abord ; 20 suffisent largement ---
  static const int _perPage = 20;

  const GithubReleaseRemoteDataSource({
    required http.Client httpClient,
    required String repository,
  })  : _httpClient = httpClient,
        _repository = repository;

  Future<List<GithubReleaseModel>> fetchReleases() async {
    final uri = Uri.parse(
      'https://api.github.com/repos/$_repository/releases?per_page=$_perPage',
    );

    try {
      final response = await _httpClient.get(
        uri,
        headers: const {'Accept': 'application/vnd.github+json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        // --- 403 / 429 : quota dépassé ; 404 : dépôt introuvable ---
        debugPrint('[Mise à jour] HTTP ${response.statusCode} sur $uri');
        return const [];
      }

      final json = jsonDecode(response.body) as List<dynamic>;
      return [
        for (final release in json)
          GithubReleaseModel.fromJson(release as Map<String, dynamic>),
      ];
    } catch (e) {
      debugPrint('[Mise à jour] Échec de la lecture des releases : $e');
      return const [];
    }
  }
}
