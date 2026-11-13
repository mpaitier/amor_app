// ============================================================================
// SATURATION / VALUE PANEL
// ============================================================================
// Carré de la teinte en cours : de gauche à droite la saturation, de haut
// en bas la luminosité. On y pose le doigt ou on le fait glisser.
// Composant "bête" : reçoit les valeurs et un callback.

import 'package:flutter/material.dart';

class SaturationValuePanel extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final void Function(double saturation, double value) onChanged;

  const SaturationValuePanel({
    super.key,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  static const double _thumbSize = 22;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        void handle(Offset position) {
          onChanged(
            (position.dx / size.width).clamp(0.0, 1.0),
            1 - (position.dy / size.height).clamp(0.0, 1.0),
          );
        }

        return GestureDetector(
          onPanDown: (details) => handle(details.localPosition),
          onPanUpdate: (details) => handle(details.localPosition),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // --- Teinte pure, éclaircie vers la gauche ---
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
                        ],
                      ),
                    ),
                  ),
                ),
                // --- Assombrie vers le bas ---
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: saturation * size.width - _thumbSize / 2,
                  top: (1 - value) * size.height - _thumbSize / 2,
                  child: _buildThumb(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumb() {
    return IgnorePointer(
      child: Container(
        width: _thumbSize,
        height: _thumbSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HSVColor.fromAHSV(1, hue, saturation, value).toColor(),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
