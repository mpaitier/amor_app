// ============================================================================
// GIF REMOTE DATA SOURCE
// ============================================================================
// Giphy API access.

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GifRemoteDataSource {
  final http.Client _httpClient;
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs/search';

  const GifRemoteDataSource({required http.Client httpClient})
      : _httpClient = httpClient;

  static String get _apiKey => dotenv.env['GIPHY_API_KEY'] ?? '';

  // --- Fetch a random gif url for the given search term ---
  Future<String?> fetchRandomGifUrl(String searchTerm) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?api_key=$_apiKey&q=${Uri.encodeComponent(searchTerm)}&limit=25&rating=g',
      );

      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>;
      if (data.isEmpty) return null;

      // --- Pick one at random among the results ---
      final random = Random();
      final picked = data[random.nextInt(data.length)];
      return picked['images']['fixed_height']['url'] as String?;
    } catch (e) {
      return null;
    }
  }
}