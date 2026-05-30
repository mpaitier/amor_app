// <<===========================================================================>>
// <<========================= DÉTAIL ÉVÉNEMENT ================================>>
// <<===========================================================================>>

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/timeline_event.dart';
import 'image_grid.dart';

class TimelineDetail extends StatelessWidget {
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
        // <<--- Titre fixe --->
        _buildTitle(),

        // <<--- Contenu scrollable --->
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDatePlace(formatter),
                const SizedBox(height: 8),
                _buildDescription(),
                const SizedBox(height: 8),
                _buildCreatedBy(),
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
          // <<--- Couleur neutre, pas de rouge Material ni de soulignage --->
          color: Colors.black87,
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildDatePlace(DateFormat formatter) {
    return _buildInfoBox(
      '${formatter.format(event.date)} • ${event.place}',
      color: const Color(0xFF616161),
    );
  }

  Widget _buildDescription() {
    return _buildInfoBox(
      event.description.replaceAll(r'\n', '\n'),
      color: Colors.black87,
    );
  }

  Widget _buildCreatedBy() {
    return _buildInfoBox(
      'Créé par ${event.who}',
      color: const Color(0xFF616161),
    );
  }

  // <<--- Box générique avec fond crème --->
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
          // <<--- Désactive le soulignage jaune du correcteur --->
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
      ),
    );
  }
}