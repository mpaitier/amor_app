// <<===========================================================================>>
// <<========================== SERVICE GIF ====================================>>
// <<===========================================================================>>
// Récupère un GIF aléatoire via l'API Giphy

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GifService {
  // <<--- Clé API Giphy (gratuite sur developers.giphy.com) --->
  static String get _apiKey => dotenv.env['GIPHY_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs/search';

  // <<--- Récupère l'URL d'un GIF aléatoire pour un terme donné --->
  static Future<String?> getRandomGifUrl(String searchTerm) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?api_key=$_apiKey&q=${Uri.encodeComponent(searchTerm)}&limit=25&rating=g',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>;

      if (data.isEmpty) return null;

      // <<--- Sélection aléatoire parmi les 25 résultats --->
      final random = Random();
      final picked = data[random.nextInt(data.length)];
      return picked['images']['fixed_height']['url'] as String?;
    } catch (e) {
      return null;
    }
  }
}