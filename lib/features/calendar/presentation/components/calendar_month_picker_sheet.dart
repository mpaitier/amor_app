// ============================================================================
// CALENDAR MONTH PICKER SHEET
// ============================================================================
// Panneau ouvert par un tap sur le mois de l'en-tête : on choisit une année
// puis un mois. Se ferme en renvoyant le CalendarMonth retenu.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/calendar_month.dart';
import '../utils/calendar_labels.dart';
import 'calendar_month_picker_button.dart';

class CalendarMonthPickerSheet extends StatefulWidget {
  final CalendarMonth selected;
  final CalendarMonth firstMonth;
  final CalendarMonth lastMonth;

  const CalendarMonthPickerSheet({
    super.key,
    required this.selected,
    required this.firstMonth,
    required this.lastMonth,
  });

  @override
  State<CalendarMonthPickerSheet> createState() =>
      _CalendarMonthPickerSheetState();
}

class _CalendarMonthPickerSheetState extends State<CalendarMonthPickerSheet> {
  // --- Pur état d'interface : l'année en cours de consultation ---
  late int _year = widget.selected.year;

  bool get _canGoBack => _year > widget.firstMonth.year;
  bool get _canGoForward => _year < widget.lastMonth.year;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 8),
            _buildYearSelector(),
            const SizedBox(height: 12),
            for (var row = 0; row < 4; row++) _buildMonthRow(row),
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

  // --- Flèches gauche/droite autour de l'année ---
  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _canGoBack ? () => setState(() => _year--) : null,
          tooltip: 'Année précédente',
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '$_year',
          style: const TextStyle(
            color: amorDarkRose,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: _canGoForward ? () => setState(() => _year++) : null,
          tooltip: 'Année suivante',
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  // --- Une ligne de trois mois ---
  Widget _buildMonthRow(int row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (var column = 0; column < 3; column++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildMonthButton(row * 3 + column + 1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthButton(int monthNumber) {
    final month = CalendarMonth(_year, monthNumber);
    final isAvailable = !month.isBefore(widget.firstMonth) &&
        !month.isAfter(widget.lastMonth);

    return CalendarMonthPickerButton(
      label: calendarMonthShortNames[monthNumber - 1],
      isSelected: month == widget.selected,
      // --- Un mois hors de la plage du calendrier n'est pas cliquable ---
      onTap: isAvailable ? () => Navigator.of(context).pop(month) : null,
    );
  }
}
