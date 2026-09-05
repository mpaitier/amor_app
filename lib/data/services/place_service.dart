// <<===========================================================================>>
// <<========================== SERVICE LIEUX ==================================>>
// <<===========================================================================>>

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// <<--- Modèle de prédiction de lieu --->
class PlacePrediction {
  final String description;
  const PlacePrediction({required this.description});
}

class PlaceService {
  static const String _host = 'api.geoapify.com';
  static const String _path = '/v1/geocode/autocomplete';

  static String get _apiKey => dotenv.env['GEOAPIFY_API_KEY']?.trim() ?? '';

  // <<--- Récupère les prédictions de lieux --->
  static Future<List<PlacePrediction>> fetchPredictions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      debugPrint(
        '[PlaceService] GEOAPIFY_API_KEY manquante ou vide. '
        'Vérifie ton fichier .env et que dotenv.load() a bien été appelé '
        'dans main.dart AVANT runApp().',
      );
      return [];
    }

    try {
      final uri = Uri.https(_host, _path, {
        'text': trimmed,
        'format': 'json',
        'lang': 'fr',
        'limit': '5',
        'apiKey': apiKey,
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        debugPrint(
          '[PlaceService] Erreur HTTP ${response.statusCode} : ${response.body}',
        );
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>? ?? [];

      final predictions = results
          .map((r) => _toPrediction(r as Map<String, dynamic>))
          .where((p) => p.description.isNotEmpty)
          .toList();

      // <<--- On évite les doublons de description --->
      final seen = <String>{};
      return predictions.where((p) => seen.add(p.description)).toList();
    } catch (e) {
      debugPrint('[PlaceService] Exception réseau : $e');
      return [];
    }
  }

  // <<--- Construit la prédiction à partir d'un résultat Geoapify --->
  static PlacePrediction _toPrediction(Map<String, dynamic> result) {
    // <<--- "formatted" est déjà une adresse lisible complète et localisée --->
    final formatted = (result['formatted'] as String?)?.trim();
    if (formatted != null && formatted.isNotEmpty) {
      return PlacePrediction(description: formatted);
    }

    // <<--- Repli manuel si jamais "formatted" est absent --->
    final name = (result['name'] as String?)?.trim();
    final city = (result['city'] as String?)?.trim();
    final country = (result['country'] as String?)?.trim();

    final parts = [name, city, country]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();

    return PlacePrediction(description: parts.join(', '));
  }
}