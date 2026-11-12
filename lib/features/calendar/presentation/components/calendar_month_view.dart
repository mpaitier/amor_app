// ============================================================================
// CALENDAR MONTH VIEW
// ============================================================================
// Enveloppe TableCalendar, stylée pour coller au thème de l'app. Lit son
// état depuis CalendarViewModel et lui renvoie les interactions utilisateur.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/calendar_viewmodel.dart';

class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // --- Material requis : CalendarScreen n'a pas de Scaffold, or
      // --- TableCalendar pose des InkWell (chevrons, bouton de format) et
      // --- des Text sans taille ni couleur. Sans ancêtre Material, les
      // --- InkWell lèvent "No Material widget found" et les textes prennent
      // --- le style de secours de Flutter (rouge, 48 px, souligné en jaune).
      // --- Placé à l'intérieur du Container pour que l'effet d'encre se
      // --- dessine au-dessus du fond blanc et non derrière.
      child: Material(
        type: MaterialType.transparency,
        child: TableCalendar(
          locale: 'fr_FR',
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: viewModel.focusedDay,
          // --- Par défaut la semaine commence le dimanche ---
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: viewModel.isSelected,
          calendarFormat: viewModel.calendarFormat,
          onDaySelected: viewModel.selectDay,
          onPageChanged: viewModel.changePage,
          onFormatChanged: viewModel.changeFormat,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Mois',
            CalendarFormat.twoWeeks: '2 semaines',
            CalendarFormat.week: 'Semaine',
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              color: amorCream,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            formatButtonTextStyle: TextStyle(color: amorDarkRose),
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: amorPink),
            todayDecoration: BoxDecoration(
              color: amorCream,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: amorDarkRose,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: amorDarkRose,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}