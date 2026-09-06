// ============================================================================
// TIMELINE EVENT CARD
// ============================================================================
// Card shown in the events list: cropped image, title, description.

import 'package:flutter/material.dart';
import '../../../../shared/widgets/cropped_image.dart';
import '../../domain/entities/timeline_event_entity.dart';

class TimelineEventCard extends StatelessWidget {
  final TimelineEventEntity event;

  const TimelineEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final images = event.imagesList;
    final firstImage = images.isNotEmpty ? images.first : '';

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
          CroppedImage(url: firstImage, imageCount: images.length),
          const SizedBox(height: 8),
          _buildTitle(),
          const SizedBox(height: 8),
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
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}