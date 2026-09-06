// ============================================================================
// TIMELINE SCREEN
// ============================================================================
// Main screen listing all memories.
// TimelineViewModel is provided once at the app root (see main.dart).

import 'package:flutter/material.dart';
import '../components/timeline_top_bar.dart';
import '../components/timeline_event_list.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: const Column(
        children: [
          // --- Top bar with sorting and add button ---
          TimelineTopBar(),

          // --- Scrollable list of events ---
          Expanded(child: TimelineEventList()),
        ],
      ),
    );
  }
}