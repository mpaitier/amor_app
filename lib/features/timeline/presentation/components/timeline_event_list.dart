// ============================================================================
// TIMELINE EVENT LIST
// ============================================================================
// Scrollable list of TimelineRow, with loading and empty states. The
// upcoming anniversaries sit at the future end of the list: on top when
// the newest memories come first, at the bottom otherwise.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../navigation/app_routes.dart';
import '../../../settings/domain/entities/upcoming_special_day.dart';
import '../../domain/entities/timeline_event_entity.dart';
import '../viewmodels/timeline_viewmodel.dart';
import '../viewmodels/upcoming_special_days_viewmodel.dart';
import 'timeline_row.dart';
import 'timeline_upcoming_row.dart';

class TimelineEventList extends StatelessWidget {
  const TimelineEventList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimelineViewModel>();
    final upcomingViewModel = context.watch<UpcomingSpecialDaysViewModel>();
    final events = viewModel.sortedEvents;
    final upcoming = upcomingViewModel.upcoming;

    if (viewModel.isLoading && events.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: amorPink),
      );
    }

    if (events.isEmpty && upcoming.isEmpty) {
      return const Center(
        child: Text(
          'Aucun souvenir pour le moment ❤️',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // --- Annonces et souvenirs dans l'ordre d'affichage ---
    final items = <Object>[
      if (viewModel.isDescending) ...upcoming.reversed,
      ...events,
      if (!viewModel.isDescending) ...upcoming,
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is UpcomingSpecialDay) {
          return TimelineUpcomingRow(
            specialDay: item,
            today: upcomingViewModel.today,
          );
        }

        final event = item as TimelineEventEntity;
        return TimelineRow(
          event: event,
          onTap: () => context.push(AppRoutes.timelineDetailPath(event.id)),
        );
      },
    );
  }
}
