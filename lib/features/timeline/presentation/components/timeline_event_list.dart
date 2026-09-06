// ============================================================================
// TIMELINE EVENT LIST
// ============================================================================
// Scrollable list of TimelineRow, with loading and empty states.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../navigation/app_routes.dart';
import '../viewmodels/timeline_viewmodel.dart';
import 'timeline_row.dart';

class TimelineEventList extends StatelessWidget {
  const TimelineEventList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimelineViewModel>();
    final events = viewModel.sortedEvents;

    if (viewModel.isLoading && events.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: amorPink),
      );
    }

    if (events.isEmpty) {
      return const Center(
        child: Text(
          'Aucun souvenir pour le moment ❤️',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = events[index];
        return TimelineRow(
          event: event,
          onTap: () => context.push(AppRoutes.timelineDetailPath(event.id)),
        );
      },
    );
  }
}