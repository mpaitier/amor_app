// ============================================================================
// HUE SLIDER
// ============================================================================
// Bande arc-en-ciel pour choisir la teinte, au doigt. Composant "bête".

import 'package:flutter/material.dart';

class HueSlider extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const HueSlider({super.key, required this.hue, required this.onChanged});

  static const double _height = 28;
  static const double _thumbSize = 28;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          void handle(Offset position) {
            onChanged((position.dx / width).clamp(0.0, 1.0) * 360);
          }

          return GestureDetector(
            onPanDown: (details) => handle(details.localPosition),
            onPanUpdate: (details) => handle(details.localPosition),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_height / 2),
                      gradient: LinearGradient(
                        colors: [
                          for (var step = 0; step <= 6; step++)
                            HSVColor.fromAHSV(1, step * 60.0, 1, 1).toColor(),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: hue / 360 * width - _thumbSize / 2,
                  top: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
