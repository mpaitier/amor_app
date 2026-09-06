// ============================================================================
// RANDOM GIF VIEWMODEL
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/usecases/get_random_gif.dart';

class RandomGifViewModel extends ChangeNotifier {
  final GetRandomGif _getRandomGif;

  String? gifUrl;
  bool isLoading = true;

  RandomGifViewModel({required GetRandomGif getRandomGif})
      : _getRandomGif = getRandomGif;

  // --- Load a random gif matching the given search term ---
  Future<void> load(String searchTerm) async {
    gifUrl = await _getRandomGif(searchTerm);
    isLoading = false;
    notifyListeners();
  }
}