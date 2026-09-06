// ============================================================================
// RANDOM GIF WIDGET
// ============================================================================
// Displays a random gif fetched from Giphy.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../viewmodels/random_gif_viewmodel.dart';

class RandomGif extends StatelessWidget {
  final String searchTerm;
  final double height;

  const RandomGif({super.key, required this.searchTerm, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RandomGifViewModel(getRandomGif: sl.getRandomGif)
        ..load(searchTerm),
      child: Consumer<RandomGifViewModel>(
        builder: (context, viewModel, _) {
          // --- Loading state ---
          if (viewModel.isLoading) {
            return SizedBox(
              height: height,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          // --- No gif available ---
          if (viewModel.gifUrl == null) return const SizedBox.shrink();

          // --- Gif display ---
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              viewModel.gifUrl!,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}