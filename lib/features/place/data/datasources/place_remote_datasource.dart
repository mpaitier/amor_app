// ============================================================================
// PLACE REMOTE DATA SOURCE
// ============================================================================
// Geoapify autocomplete API access.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlaceRemoteDataSource {
  final http.Client _httpClient;
  static const String _host = 'api.geoapify.com';
  static const String _path = '/v1/geocode/autocomplete';

  const PlaceRemoteDataSource({required http.Client httpClient})
      : _httpClient = httpClient;

  static String get _apiKey => dotenv.env['GEOAPIFY_API_KEY']?.trim() ?? '';

  // --- Fetch raw place predictions matching a query ---
  Future<List<Map<String, dynamic>>> fetchPredictions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      debugPrint(
        '[PlaceRemoteDataSource] Missing GEOAPIFY_API_KEY. '
        'Check your .env file and that dotenv.load() ran before runApp().',
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

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        debugPrint(
          '[PlaceRemoteDataSource] HTTP error ${response.statusCode}: ${response.body}',
        );
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['results'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[PlaceRemoteDataSource] Network exception: $e');
      return [];
    }
  }
}