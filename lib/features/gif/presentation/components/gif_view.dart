// ============================================================================
// GIF VIEW
// ============================================================================
// Affiche un GIF, centré. Un tap copie son lien. Un bouton optionnel, à sa
// droite, en tire un autre ; une place vide de même largeur à gauche garde
// le GIF au centre. Composant "bête" : reçoit l'adresse, l'état de
// chargement et le callback de changement.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class GifView extends StatefulWidget {
  final String gifUrl;
  final bool isLoading;
  final double height;

  // --- Null : pas de bouton pour changer de GIF (affichage seul) ---
  final VoidCallback? onRefresh;

  const GifView({
    super.key,
    required this.gifUrl,
    this.isLoading = false,
    this.height = 100,
    this.onRefresh,
  });

  @override
  State<GifView> createState() => _GifViewState();
}

class _GifViewState extends State<GifView> {
  // --- Largeur réservée de chaque côté quand il y a le bouton ---
  static const double _sideWidth = 48;

  // --- Pur état d'interface : le badge "Lien copié" est-il affiché ? ---
  bool _showCopied = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.gifUrl));
    if (!mounted) return;

    setState(() => _showCopied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasButton = widget.onRefresh != null;

    // --- Material transparent : l'écran de détail d'un souvenir n'a pas
    // --- de Scaffold, ses textes seraient sinon soulignés en jaune ---
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: widget.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasButton) const SizedBox(width: _sideWidth),
            Flexible(child: _buildGif()),
            if (hasButton)
              SizedBox(
                width: _sideWidth,
                child: Center(child: _buildRefreshButton()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGif() {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (widget.gifUrl.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _copyLink,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              widget.gifUrl,
              height: widget.height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            if (_showCopied) Positioned.fill(child: _buildCopiedBadge()),
          ],
        ),
      ),
    );
  }

  Widget _buildCopiedBadge() {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.center,
        color: Colors.black.withValues(alpha: 0.45),
        child: const Text(
          'Lien copié',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Flèche circulaire : tire un autre GIF ---
  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: widget.isLoading ? null : widget.onRefresh,
      tooltip: 'Un autre GIF',
      icon: const Icon(Icons.refresh, color: amorDarkRose),
    );
  }
}
