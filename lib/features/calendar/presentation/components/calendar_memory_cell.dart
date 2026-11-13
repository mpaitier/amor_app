// ============================================================================
// CALENDAR MEMORY CELL
// ============================================================================
// Case d'un jour avec souvenir : le numéro monte en petit au-dessus de la
// case, dont l'intérieur est rempli par l'image de couverture. Si le jour
// est aussi un jour spécial, sa bordure entoure la couverture et son emoji
// apparaît en pastille.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import 'calendar_day_number_label.dart';

class CalendarMemoryCell extends StatelessWidget {
  final int day;
  final String coverUrl;
  final VoidCallback onTap;

  // --- Renseignés seulement quand le jour est aussi un jour spécial ---
  final int? borderColor;
  final String? badgeEmoji;

  const CalendarMemoryCell({
    super.key,
    required this.day,
    required this.coverUrl,
    required this.onTap,
    this.borderColor,
    this.badgeEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor;
    final badge = badgeEmoji;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CalendarDayNumberLabel(day: day),

        // --- Couverture, avec l'effet d'encre dessiné par-dessus l'image ---
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCover(),
                if (border != null) _buildBorder(border),
                if (badge != null) _buildBadge(badge),
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

  // --- Bordure du jour spécial, posée sur la couverture ---
  Widget _buildBorder(int color) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(color), width: 2),
      ),
    );
  }

  // --- Emoji du jour spécial, en pastille dans le coin ---
  Widget _buildBadge(String emoji) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        width: 18,
        height: 18,
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 10, height: 1.0)),
      ),
    );
  }
}
