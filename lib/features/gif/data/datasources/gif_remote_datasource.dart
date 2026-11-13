// ============================================================================
// GIF REMOTE DATA SOURCE
// ============================================================================
// Giphy API access. Les échecs sont journalisés dans la console (debugPrint)
// pour ne plus être silencieux : clé absente, quota dépassé, réponse vide...

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GifRemoteDataSource {
  final http.Client _httpClient;
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs/search';

  // --- Au-delà, la requête est abandonnée plutôt que de bloquer le GIF ---
  static const Duration _timeout = Duration(seconds: 10);

  const GifRemoteDataSource({required http.Client httpClient})
      : _httpClient = httpClient;

  static String get _apiKey => dotenv.env['GIPHY_API_KEY'] ?? '';

  // --- Fetch a random gif url for the given search term ---
  Future<String?> fetchRandomGifUrl(String searchTerm) async {
    if (_apiKey.isEmpty) {
      debugPrint('[Giphy] GIPHY_API_KEY absente du fichier .env');
      return null;
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl?api_key=$_apiKey&q=${Uri.encodeComponent(searchTerm)}&limit=25&rating=g',
      );

      final response = await _httpClient.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        // --- 429 : quota dépassé ; 401 / 403 : clé refusée ---
        debugPrint('[Giphy] HTTP ${response.statusCode} pour "$searchTerm"');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>;

      // --- Seuls les résultats qui ont bien une adresse sont gardés ---
      final urls = <String>[
        for (final item in data)
          if (_urlOf(item) != null) _urlOf(item)!,
      ];
      if (urls.isEmpty) {
        debugPrint('[Giphy] Aucun résultat pour "$searchTerm"');
        return null;
      }

      // --- Pick one at random among the results ---
      return urls[Random().nextInt(urls.length)];
    } catch (e) {
      debugPrint('[Giphy] Échec de la requête pour "$searchTerm" : $e');
      return null;
    }
  }

  // --- Adresse de la version "fixed_height" d'un résultat, si présente ---
  static String? _urlOf(dynamic item) {
    if (item is! Map<String, dynamic>) return null;
    final images = item['images'];
    if (images is! Map<String, dynamic>) return null;
    final fixedHeight = images['fixed_height'];
    if (fixedHeight is! Map<String, dynamic>) return null;
    final url = fixedHeight['url'];
    return url is String && url.isNotEmpty ? url : null;
  }
}
