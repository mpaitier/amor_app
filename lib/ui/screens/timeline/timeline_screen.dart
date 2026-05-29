// <<===========================================================================>>
// <<========================== ÉCRAN TIMELINE =================================>>
// <<===========================================================================>>
// Équivalent de Timeline.kt — liste principale des souvenirs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../navigation/screen.dart';
import '../../../ui/components/timeline/timeline_row.dart';
import '../../../ui/viewmodels/timeline_viewmodel.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // <<--- Ordre de tri --->
  bool _isDescending = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimelineViewModel>();

    // <<--- Tri des événements --->
    final sortedEvents = [...viewModel.events]..sort(
        (a, b) => _isDescending
            ? b.date.compareTo(a.date)
            : a.date.compareTo(b.date),
      );

    return Container(
      color: amorCream,
      child: Column(
        children: [
          // <<--- Barre du haut --->
          _buildTopBar(context),

          // <<--- Liste des événements --->
          Expanded(
            child: _buildEventList(context, sortedEvents, viewModel.isLoading),
          ),
        ],
      ),
    );
  }

  // <<--- Barre du haut avec tri et ajout --->
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      child: Row(
        children: [
          // <<--- Bouton tri --->
          IconButton(
            onPressed: () => setState(() => _isDescending = !_isDescending),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time,
                    color: Color(0xFF904B3C), size: 18),
                Icon(
                  _isDescending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 18,
                ),
              ],
            ),
          ),

          // <<--- Titre centré --->
          Expanded(
            child: Container(
              color: amorCreamTransparent,
              child: const Text(
                'Notre histoire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // <<--- Bouton ajout --->
          IconButton(
            onPressed: () => context.push(AppRoutes.addTimeline),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // <<--- Liste scrollable des événements --->
  Widget _buildEventList(
    BuildContext context,
    List sortedEvents,
    bool isLoading,
  ) {
    if (isLoading && sortedEvents.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: amorPink),
      );
    }

    if (sortedEvents.isEmpty) {
      return const Center(
        child: Text(
          'Aucun souvenir pour le moment ❤️',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
      itemCount: sortedEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return TimelineRow(
          event: event,
          onTap: () => context.push(
            AppRoutes.timelineDetailPath(event.id),
          ),
        );
      },
    );
  }
}