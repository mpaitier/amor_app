// ============================================================================
// EVENT DETAIL TOP BAR
// ============================================================================
// Back button + options menu trigger.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class EventDetailTopBar extends StatelessWidget {
  final VoidCallback onToggleMenu;

  const EventDetailTopBar({
    super.key,
    required this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Back button ---
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new),
          ),

          // --- Options menu trigger ---
          IconButton(
            onPressed: onToggleMenu,
            icon: const Icon(Icons.more_vert, color: amorDarkRose),
          ),
        ],
      ),
    );
  }
}