// ============================================================================
// PLACE AUTOCOMPLETE FIELD
// ============================================================================
// Text field with a suggestions dropdown, backed by PlaceAutocompleteViewModel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../viewmodels/place_autocomplete_viewmodel.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final String initialValue;
  final void Function(String place) onPlaceSelected;

  const PlaceAutocompleteField({
    super.key,
    required this.initialValue,
    required this.onPlaceSelected,
  });

  @override
  State<PlaceAutocompleteField> createState() =>
      _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Forward free-typed text to the parent AND to the search debounce ---
  void _onTextChanged(PlaceAutocompleteViewModel viewModel, String value) {
    widget.onPlaceSelected(value);
    viewModel.onQueryChanged(value);
  }

  void _selectPrediction(
    PlaceAutocompleteViewModel viewModel,
    String description,
  ) {
    _controller.text = description;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    widget.onPlaceSelected(description);
    viewModel.clearPredictions();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlaceAutocompleteViewModel(searchPlaces: sl.searchPlaces),
      child: Consumer<PlaceAutocompleteViewModel>(
        builder: (context, viewModel, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Icon + field on the same row ---
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) => _onTextChanged(viewModel, value),
                    decoration: const InputDecoration(
                      hintText: 'Lieu...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (viewModel.isSearching)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            // --- Suggestions ---
            if (viewModel.predictions.isNotEmpty)
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
                  children: viewModel.predictions.map((p) {
                    return InkWell(
                      onTap: () => _selectPrediction(viewModel, p.description),
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
        ),
      ),
    );
  }
}