// ============================================================================
// EVENT DETAIL SCREEN
// ============================================================================
// Full detail view of a single memory, with edit/delete menu.
// TimelineViewModel is provided once at the app root (see main.dart).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../navigation/app_routes.dart';
import '../../domain/entities/timeline_event_entity.dart';
import '../viewmodels/timeline_viewmodel.dart';
import '../components/timeline_detail_view.dart';
import '../components/event_detail_top_bar.dart';
import '../components/event_detail_options_menu.dart';
import '../components/delete_event_dialog.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  // --- Pure UI state: is the options menu currently open? ---
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimelineViewModel>();
    final TimelineEventEntity? event = viewModel.eventById(widget.eventId);

    if (event == null) {
      return Scaffold(
        body: Center(
          child: Text('Événement ${widget.eventId} introuvable'),
        ),
      );
    }

    return Container(
      color: amorCream,
      // --- Stack au niveau de l'écran entier : le menu, peint en dernier,
      // --- passe systématiquement au-dessus du contenu scrollable ---
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // --- Top bar with back button and menu trigger ---
              EventDetailTopBar(
                onToggleMenu: () => setState(() => _showMenu = !_showMenu),
              ),

              // --- Detail content ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TimelineDetailView(event: event),
                ),
              ),
            ],
          ),

          // --- Options menu, positioned over everything else ---
          if (_showMenu)
            EventDetailOptionsMenu(
              onEdit: () {
                setState(() => _showMenu = false);
                context.push(
                  AppRoutes.addTimeline,
                  extra: {'eventToEdit': event},
                );
              },
              onDelete: () {
                setState(() => _showMenu = false);
                _confirmDelete(context, viewModel, event);
              },
            ),
        ],
      ),
    );
  }

  // --- Confirmation dialog before deletion ---
  void _confirmDelete(
    BuildContext context,
    TimelineViewModel viewModel,
    TimelineEventEntity event,
  ) {
    showDialog(
      context: context,
      builder: (_) => DeleteEventDialog(
        eventTitle: event.title,
        onConfirm: () async {
          Navigator.of(context).pop();
          final success = await viewModel.deleteEvent(event.id);
          if (success && context.mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Souvenir supprimé 🗑️')),
            );
          }
        },
      ),
    );
  }
}