// ============================================================================
// TIMELINE TOP BAR
// ============================================================================
// Sort toggle + centered title + "add event" button.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../navigation/app_routes.dart';
import '../viewmodels/timeline_viewmodel.dart';

class TimelineTopBar extends StatelessWidget {
  const TimelineTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimelineViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      child: Row(
        children: [
          // --- Sort button ---
          GestureDetector(
            onTap: viewModel.toggleSortOrder,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: amorCream,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time,
                      color: Color(0xFF904B3C), size: 18),
                  const SizedBox(width: 4),
                  Icon(
                    viewModel.isDescending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 18,
                    color: const Color(0xFF904B3C),
                  ),
                ],
              ),
            ),
          ),

          // --- Centered title ---
          Expanded(
            child: Container(
              color: amorCreamTransparent,
              child: const Text(
                'Notre histoire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF703348),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,
                ),
              ),
            ),
          ),

          // --- Add event button ---
          IconButton(
            onPressed: () => context.push(AppRoutes.addTimeline),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}