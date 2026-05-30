// <<===========================================================================>>
// <<========================== WIDGET GIF ALÉATOIRE ===========================>>
// <<===========================================================================>>
// Affiche un GIF aléatoire depuis Giphy

import 'package:flutter/material.dart';
import '../data/services/gif_service.dart';

class RandomGif extends StatefulWidget {
  // <<--- Paramètres --->
  final String searchTerm;
  final double height;

  const RandomGif({
    super.key,
    required this.searchTerm,
    this.height = 100,
  });

  @override
  State<RandomGif> createState() => _RandomGifState();
}

class _RandomGifState extends State<RandomGif> {
  // <<--- URL du GIF chargé --->
  String? _gifUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGif();
  }

  // <<--- Chargement du GIF --->
  Future<void> _loadGif() async {
    final url = await GifService.getRandomGifUrl(widget.searchTerm);
    if (mounted) {
      setState(() {
        _gifUrl = url;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // <<--- État de chargement --->
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // <<--- Pas de GIF disponible --->
    if (_gifUrl == null) return const SizedBox.shrink();

    // <<--- Affichage du GIF --->
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        _gifUrl!,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}