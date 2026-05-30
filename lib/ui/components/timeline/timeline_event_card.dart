// <<===========================================================================>>
// <<========================= CARTE ÉVÉNEMENT TIMELINE ========================>>
// <<===========================================================================>>

import 'package:flutter/material.dart';
import '../../../data/models/timeline_event.dart';
import '../../../widgets/cropped_image.dart';

class TimelineEventCard extends StatelessWidget {
  final TimelineEvent event;

  const TimelineEventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final images = event.getImagesList();
    final firstImage = images.isNotEmpty ? images.first : '';
    final totalImages = images.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // <<--- Image principale avec badge --->
          CroppedImage(url: firstImage, imageCount: totalImages),

          const SizedBox(height: 8),

          // <<--- Titre --->
          _buildTitle(),

          const SizedBox(height: 8),

          // <<--- Description --->
          _buildDescription(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        event.title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF703348),
          // <<--- Désactive toute décoration (soulignage, rouge correcteur) --->
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Text(
        event.description.replaceAll(r'\n', '\n'),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          // <<--- Idem : désactive le soulignage --->
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}