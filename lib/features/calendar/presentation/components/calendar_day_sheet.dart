// ============================================================================
// CALENDAR DAY SHEET
// ============================================================================
// Panneau ouvert quand un jour contient plusieurs éléments : il liste ses
// dates importantes et ses souvenirs. Se ferme en renvoyant l'élément
// touché (un ImportantDateEntity ou un TimelineEventEntity).

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../important_dates/domain/entities/important_date_entity.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../utils/calendar_labels.dart';

class CalendarDaySheet extends StatelessWidget {
  final DateTime day;
  final List<TimelineEventEntity> memories;
  final List<ImportantDateEntity> importantDates;

  const CalendarDaySheet({
    super.key,
    required this.day,
    required this.memories,
    required this.importantDates,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 12),
            Text(
              formatDayMonthYear(day),
              style: const TextStyle(
                color: amorDarkRose,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // --- Flexible : la liste défile si le jour est très chargé ---
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final date in importantDates)
                    _buildImportantDate(context, date),
                  for (final memory in memories) _buildMemory(context, memory),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: outlineVariantLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildImportantDate(BuildContext context, ImportantDateEntity date) {
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Center(
          child: Text(
            date.emoji,
            style: const TextStyle(fontSize: 22, height: 1.0),
          ),
        ),
      ),
      title: Text(date.title),
      subtitle: const Text('Date importante'),
      onTap: () => Navigator.of(context).pop<Object>(date),
    );
  }

  Widget _buildMemory(BuildContext context, TimelineEventEntity memory) {
    return ListTile(
      leading: const SizedBox(
        width: 32,
        child: Center(child: Icon(Icons.favorite, color: amorDarkRose)),
      ),
      title: Text(memory.title),
      subtitle: const Text('Souvenir'),
      onTap: () => Navigator.of(context).pop<Object>(memory),
    );
  }
}
