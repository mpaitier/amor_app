// ============================================================================
// EVENT DETAIL TOP BAR
// ============================================================================
// Back button + options menu trigger.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'event_detail_options_menu.dart';

class EventDetailTopBar extends StatelessWidget {
  final bool showMenu;
  final VoidCallback onToggleMenu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventDetailTopBar({
    super.key,
    required this.showMenu,
    required this.onToggleMenu,
    required this.onEdit,
    required this.onDelete,
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

          // --- Options menu ---
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onToggleMenu,
                icon: const Icon(Icons.more_vert, color: amorDarkRose),
              ),
              if (showMenu)
                EventDetailOptionsMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}