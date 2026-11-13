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
    if (widget.isLoading) return _buildSpinner();

    // --- Rien reçu de Giphy : on le dit, plutôt qu'un vide muet ---
    if (widget.gifUrl.isEmpty) {
      return widget.onRefresh == null
          ? const SizedBox.shrink()
          : _buildPlaceholder('Pas de GIF');
    }

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
              // --- Un GIF pèse vite plusieurs Mo. Tant que sa première image
              // --- n'est pas à l'écran (attente de la réponse, téléchargement,
              // --- décodage), on montre qu'il arrive ---
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return _buildSpinner();
              },
              errorBuilder: (_, __, ___) =>
                  _buildPlaceholder('GIF indisponible'),
            ),
            if (_showCopied) Positioned.fill(child: _buildCopiedBadge()),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinner() {
    return SizedBox(
      width: widget.height,
      height: widget.height,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  // --- Cadre de la taille du GIF, avec un message ---
  Widget _buildPlaceholder(String message) {
    return Container(
      width: widget.height * 1.4,
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: amorCreamTransparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gif_box_outlined, color: outlineLight),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(color: outlineLight, fontSize: 13),
          ),
        ],
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
