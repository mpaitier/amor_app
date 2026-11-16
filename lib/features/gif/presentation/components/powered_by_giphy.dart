// ============================================================================
// POWERED BY GIPHY
// ============================================================================
// Mention "Powered by GIPHY" exigée par les conditions de l'API GIPHY
// partout où un de ses GIF est affiché. Posée en bas à droite du GIF par
// GifView.
// Pastille sombre (le fond du logo) : "Powered by", puis le logo GIPHY de
// assets/images/powered_by_giphy.png. Si l'image manque, le mot GIPHY en
// gras le remplace. Composant "bête".

import 'package:flutter/material.dart';

class PoweredByGiphy extends StatelessWidget {
  static const String logoAsset = 'assets/images/powered_by_giphy.png';

  // --- Fond du logo officiel, pour que la pastille et l'image se fondent ---
  static const Color _background = Color(0xFF121119);

  final double height;

  const PoweredByGiphy({super.key, this.height = 14});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: height * 0.55,
      height: 1,
      decoration: TextDecoration.none,
    );

    return Semantics(
      label: 'Powered by GIPHY',
      excludeSemantics: true,
      child: Container(
        height: height,
        padding: const EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Powered by', style: textStyle),
            // --- Le logo a ses propres marges sombres sur les côtés ---
            Image.asset(
              logoAsset,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'GIPHY',
                  style: textStyle.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
