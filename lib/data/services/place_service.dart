// <<===========================================================================>>
// <<========================== SERVICE LIEUX ==================================>>
// <<===========================================================================>>

import 'dart:convert';
import 'package:http/http.dart' as http;

// <<--- Modèle de prédiction de lieu --->
class PlacePrediction {
  final String description;
  const PlacePrediction({required this.description});
}

class PlaceService {
  // <<--- URL de base de l'API Photon --->
  static const String _baseUrl = 'https://photon.komoot.io/api/';

  // <<--- Récupère les prédictions de lieux --->
  static Future<List<PlacePrediction>> fetchPredictions(String query) async {
    if (query.length < 3) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(query)}&lang=fr&limit=5',
      );
      final response = await http.get(uri);

      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>;

      return features.map((feature) {
        final props = feature['properties'] as Map<String, dynamic>;

        // <<--- Construction de la description : Nom, Ville, Pays --->
        final name = props['name'] as String? ?? '';
        final city = props['city'] as String? ?? '';
        final country = props['country'] as String? ?? '';

        final parts = [name, city, country]
            .where((s) => s.isNotEmpty)
            .toList();

        return PlacePrediction(description: parts.join(', '));
      }).toList();
    } catch (e) {
      return [];
    }
  }
}