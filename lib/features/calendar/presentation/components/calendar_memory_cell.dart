// ============================================================================
// CALENDAR MEMORY CELL
// ============================================================================
// Case d'un jour avec souvenir : le numéro monte en petit au-dessus de la
// case, dont l'intérieur est rempli par l'image de couverture.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/calendar_layout.dart';

class CalendarMemoryCell extends StatelessWidget {
  final int day;
  final String coverUrl;
  final VoidCallback onTap;

  const CalendarMemoryCell({
    super.key,
    required this.day,
    required this.coverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Numéro du jour, au-dessus de la case ---
        SizedBox(
          height: CalendarLayout.dayNumberHeight,
          child: Center(
            child: Text(
              '$day',
              style: const TextStyle(
                color: amorDarkRose,
                fontSize: 11,
                height: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // --- Couverture, avec l'effet d'encre dessiné par-dessus l'image ---
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCover(),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(onTap: onTap),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCover() {
    if (coverUrl.isEmpty) return _buildPlaceholder();

    return CachedNetworkImage(
      imageUrl: coverUrl,
      fit: BoxFit.cover,
      // --- Une vignette suffit : inutile de décoder l'image en grand ---
      memCacheWidth: 200,
      placeholder: (context, url) => const ColoredBox(
        color: primaryContainerLight,
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  // --- Souvenir sans image, ou image introuvable ---
  Widget _buildPlaceholder() {
    return const ColoredBox(
      color: primaryContainerLight,
      child: Center(
        child: Icon(Icons.favorite, color: amorDarkRose, size: 18),
      ),
    );
  }
}
