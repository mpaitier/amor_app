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

enum _EventMenuAction { edit, delete }

class EventDetailScreen extends StatelessWidget {
  // <<--- Paramètres --->
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimelineViewModel>();
    final event = viewModel.events
        .where((e) => e.id == eventId)
        .firstOrNull;

    if (event == null) {
      return Scaffold(
        body: Center(
          child: Text('Événement $eventId introuvable'),
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

          // <<--- Menu options : PopupMenuButton natif --->
          // <<--- Rendu via l'Overlay de l'app -> toujours au-dessus du --->
          // <<--- reste de l'écran, aucun souci de z-index possible.   --->
          PopupMenuButton<_EventMenuAction>(
            icon: const Icon(Icons.more_vert, color: amorDarkRose),
            color: amorCream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (action) => _handleMenuAction(
              context,
              action,
              viewModel,
              event,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _EventMenuAction.edit,
                child: _buildMenuOptionContent(
                  label: 'Modifier',
                  icon: Icons.edit,
                  labelColor: Colors.black,
                  iconColor: amorDarkRose,
                ),
              ),
              PopupMenuItem(
                value: _EventMenuAction.delete,
                child: _buildMenuOptionContent(
                  label: 'Supprimer',
                  icon: Icons.delete,
                  labelColor: Colors.red,
                  iconColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // <<--- Contenu visuel d'une option du menu --->
  Widget _buildMenuOptionContent({
    required String label,
    required IconData icon,
    required Color labelColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: labelColor)),
      ],
    );
  }

  // <<--- Dispatch de l'action choisie dans le menu --->
  void _handleMenuAction(
    BuildContext context,
    _EventMenuAction action,
    TimelineViewModel viewModel,
    event,
  ) {
    switch (action) {
      case _EventMenuAction.edit:
        viewModel.setSelectedEventForEdit(event);
        context.push(
          AppRoutes.addTimeline,
          extra: {'eventToEdit': event},
        );
        break;
      case _EventMenuAction.delete:
        _confirmDelete(context, viewModel, event);
        break;
    }
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