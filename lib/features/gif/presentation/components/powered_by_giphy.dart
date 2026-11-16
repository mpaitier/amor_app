// ============================================================================
// POWERED BY GIPHY
// ============================================================================
// Mention "Powered by GIPHY" exigée par les conditions de l'API GIPHY
// partout où un de ses GIF est affiché. Posée en bas à droite du GIF par
// GifView.
// Le logo officiel se télécharge sur le site développeurs de GIPHY ; placé
// dans assets/images/powered_by_giphy.png, il est affiché tel quel. En son
// absence, une pastille de texte prend sa place. Composant "bête".

import 'package:flutter/material.dart';

class PoweredByGiphy extends StatelessWidget {
  static const String logoAsset = 'assets/images/powered_by_giphy.png';

  final double height;

  const PoweredByGiphy({super.key, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Powered by GIPHY',
      child: Image.asset(
        logoAsset,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildTextMark(),
      ),
    );
  }

  // --- Pastille noire, texte blanc : lisible sur n'importe quel GIF ---
  Widget _buildTextMark() {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text.rich(
        const TextSpan(
          children: [
            TextSpan(text: 'Powered by '),
            TextSpan(
              text: 'GIPHY',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: height * 0.6,
          height: 1,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
