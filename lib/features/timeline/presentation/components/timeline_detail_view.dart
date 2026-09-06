// ============================================================================
// TIMELINE DETAIL VIEW
// ============================================================================
// Full detail content of a single memory: title, date, place,
// description, author and image grid.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/timeline_event_entity.dart';
import 'image_grid.dart';

class TimelineDetailView extends StatelessWidget {
  final TimelineEventEntity event;

  const TimelineDetailView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy', 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Fixed title ---
        _buildTitle(),

        // --- Scrollable content ---
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBox(
                  '${formatter.format(event.date)} • ${event.place}',
                  color: const Color(0xFF616161),
                ),
                const SizedBox(height: 8),
                _buildInfoBox(
                  event.description.replaceAll(r'\n', '\n'),
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                _buildInfoBox(
                  'Créé par ${event.who}',
                  color: const Color(0xFF616161),
                ),
                const SizedBox(height: 16),
                ImageGrid(event: event),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        event.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
      ),
    );
  }

  // --- Generic cream-background info box ---
  Widget _buildInfoBox(String text, {Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: amorCreamTransparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: color ?? Colors.black87,
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
      ),
    );
  }
}