// ============================================================================
// PLACE AUTOCOMPLETE VIEWMODEL
// ============================================================================
// Debounces user input and queries place predictions.
// Debounce 400ms: Geoapify (3000 free req/day) has no strict 1 req/s
// limit like Nominatim, so we can stay reactive.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/place_prediction_entity.dart';
import '../../domain/usecases/search_places.dart';

class PlaceAutocompleteViewModel extends ChangeNotifier {
  final SearchPlaces _searchPlaces;
  static const Duration _debounceDelay = Duration(milliseconds: 400);

  Timer? _debounce;
  List<PlacePredictionEntity> predictions = [];
  bool isSearching = false;

  PlaceAutocompleteViewModel({required SearchPlaces searchPlaces})
      : _searchPlaces = searchPlaces;

  // --- Trigger a debounced search for the given input ---
  void onQueryChanged(String value) {
    _debounce?.cancel();

    if (value.trim().length < 3) {
      if (predictions.isNotEmpty || isSearching) {
        predictions = [];
        isSearching = false;
        notifyListeners();
      }
      return;
    }

    isSearching = true;
    notifyListeners();

    _debounce = Timer(_debounceDelay, () async {
      final results = await _searchPlaces(value);
      predictions = results;
      isSearching = false;
      notifyListeners();
    });
  }

  void clearPredictions() {
    predictions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}