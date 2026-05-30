// <<===========================================================================>>
// <<=================== WIDGET AUTOCOMPLÉTION LIEU ============================>>
// <<===========================================================================>>

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

    if (value.length < 3) {
      if (_predictions.isNotEmpty) setState(() => _predictions = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await PlaceService.fetchPredictions(value);
      if (mounted) setState(() => _predictions = results);
    });
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
                  onTap: () {
                    _controller.text = p.description;
                    widget.onPlaceSelected(p.description);
                    setState(() => _predictions = []);
                    FocusScope.of(context).unfocus();
                  },
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