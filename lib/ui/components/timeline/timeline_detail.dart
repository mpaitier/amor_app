// <<===========================================================================>>
// <<========================= DÉTAIL ÉVÉNEMENT ================================>>
// <<===========================================================================>>
// Équivalent de Detail.kt — contenu scrollable du détail d'un événement

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/timeline_event.dart';
import 'image_grid.dart';

class TimelineDetail extends StatelessWidget {
  // <<--- Paramètres --->
  final TimelineEvent event;

  const TimelineDetail({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy', 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // <<--- Section fixe : Titre --->
        _buildTitle(),

        // <<--- Section scrollable --->
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // <<--- Date et lieu --->
                _buildDatePlace(formatter),

                const SizedBox(height: 8),

                // <<--- Description --->
                _buildDescription(),

                const SizedBox(height: 8),

                // <<--- Créé par --->
                _buildCreatedBy(),

                const SizedBox(height: 16),

                // <<--- Grille d'images --->
                ImageGrid(event: event),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // <<--- Titre de l'événement --->
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        event.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // <<--- Date et lieu --->
  Widget _buildDatePlace(DateFormat formatter) {
    return _buildInfoBox(
      '${formatter.format(event.date)} • ${event.place}',
      color: const Color(0xFF616161),
    );
  }

  // <<--- Description --->
  Widget _buildDescription() {
    return _buildInfoBox(
      event.description.replaceAll(r'\n', '\n'),
    );
  }

  // <<--- Créé par --->
  Widget _buildCreatedBy() {
    return _buildInfoBox(
      'Créé par ${event.who}',
      color: const Color(0xFF616161),
    );
  }

  // <<--- Box d'information générique --->
  Widget _buildInfoBox(String text, {Color? color}) {
    return Container(
      width: double.infinity,
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
          color: color,
        ),
      ),
    );
  }
}