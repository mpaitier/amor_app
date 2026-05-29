// <<===========================================================================>>
// <<======================== ÉCRAN DÉTAIL ÉVÉNEMENT ===========================>>
// <<===========================================================================>>
// Équivalent de EventDetail.kt — détail complet d'un souvenir

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../navigation/screen.dart';
import '../../../ui/components/timeline/timeline_detail.dart';
import '../../../ui/viewmodels/timeline_viewmodel.dart';

class EventDetailScreen extends StatefulWidget {
  // <<--- Paramètres --->
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  // <<--- État du menu --->
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimelineViewModel>();
    final event = viewModel.events
        .where((e) => e.id == widget.eventId)
        .firstOrNull;

    if (event == null) {
      return Scaffold(
        body: Center(
          child: Text('Événement ${widget.eventId} introuvable'),
        ),
      );
    }

    return Container(
      color: amorCream,
      child: Column(
        children: [
          // <<--- Barre du haut --->
          _buildTopBar(context, viewModel, event),

          // <<--- Contenu détail --->
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TimelineDetail(event: event),
            ),
          ),
        ],
      ),
    );
  }

  // <<--- Barre du haut avec retour et options --->
  Widget _buildTopBar(BuildContext context, TimelineViewModel viewModel, event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // <<--- Bouton retour --->
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new),
          ),

          // <<--- Menu options --->
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => setState(() => _showMenu = true),
                icon: const Icon(Icons.more_vert, color: amorDarkRose),
              ),
              if (_showMenu) _buildDropdownMenu(context, viewModel, event),
            ],
          ),
        ],
      ),
    );
  }

  // <<--- Menu déroulant Modifier / Supprimer --->
  Widget _buildDropdownMenu(
    BuildContext context,
    TimelineViewModel viewModel,
    event,
  ) {
    return Positioned(
      top: 40,
      right: 0,
      child: Material(
        color: amorCream,
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // <<--- Option Modifier --->
            _buildMenuOption(
              label: 'Modifier',
              icon: Icons.edit,
              color: Colors.black,
              iconColor: amorDarkRose,
              onTap: () {
                setState(() => _showMenu = false);
                viewModel.setSelectedEventForEdit(event);
                context.push(
                  AppRoutes.addTimeline,
                  extra: {'eventToEdit': event},
                );
              },
            ),

            // <<--- Option Supprimer --->
            _buildMenuOption(
              label: 'Supprimer',
              icon: Icons.delete,
              color: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                setState(() => _showMenu = false);
                _confirmDelete(context, viewModel, event);
              },
            ),
          ],
        ),
      ),
    );
  }

  // <<--- Option individuelle du menu --->
  Widget _buildMenuOption({
    required String label,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  // <<--- Dialog de confirmation de suppression --->
  void _confirmDelete(
    BuildContext context,
    TimelineViewModel viewModel,
    event,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce souvenir ?'),
        content: Text(
          'Es-tu sûr(e) de vouloir supprimer "${event.title}" ? Cette action est définitive.',
        ),
        // <<--- Correction : confirmTextColor n'existe pas, on passe par actions --->
        actions: [
          // <<--- Annuler --->
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          // <<--- Confirmer --->
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await viewModel.deleteEvent(event.id);
              if (success && context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Souvenir supprimé 🗑️')),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}