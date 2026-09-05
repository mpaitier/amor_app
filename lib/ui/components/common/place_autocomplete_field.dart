// <<===========================================================================>>
// <<=================== WIDGET AUTOCOMPLÉTION LIEU ============================>>
// <<===========================================================================>>
// <<--- Debounce 400ms : Geoapify (3000 req/jour gratuits) n'impose pas la --->
// <<--- limite stricte de 1 req/s de Nominatim, on peut rester réactif.    --->

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/place_service.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final String initialValue;
  final void Function(String place) onPlaceSelected;

  const PlaceAutocompleteField({
    super.key,
    required this.initialValue,
    required this.onPlaceSelected,
  });

  @override
  State<PlaceAutocompleteField> createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  late final TextEditingController _controller;
  List<PlacePrediction> _predictions = [];
  Timer? _debounce;
  bool _isSearching = false;

  static const Duration _debounceDelay = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();

    // <<--- On informe aussi le parent en direct (saisie libre possible) --->
    widget.onPlaceSelected(value);

    if (value.trim().length < 3) {
      if (_predictions.isNotEmpty || _isSearching) {
        setState(() {
          _predictions = [];
          _isSearching = false;
        });
      }
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(_debounceDelay, () async {
      final results = await PlaceService.fetchPredictions(value);
      if (mounted) {
        setState(() {
          _predictions = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectPrediction(PlacePrediction prediction) {
    _controller.text = prediction.description;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    widget.onPlaceSelected(prediction.description);
    setState(() => _predictions = []);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // <<--- Icône + champ sur la même ligne --->
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onTextChanged,
                decoration: const InputDecoration(
                  hintText: 'Lieu...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_isSearching)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),

        // <<--- Suggestions --->
        if (_predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _predictions.map((p) {
                return InkWell(
                  onTap: () => _selectPrediction(p),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: amorDarkRose),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
