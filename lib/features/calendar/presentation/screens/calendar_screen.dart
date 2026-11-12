// ============================================================================
// CALENDAR SCREEN
// ============================================================================
// Vue mensuelle des souvenirs. Vide de tout événement pour l'instant — le
// flux d'événements sera branché une fois les couches domain/data créées.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../navigation/app_routes.dart';
import '../../../navigation/presentation/components/floating_nav_menu.dart';
import '../components/calendar_top_bar.dart';
import '../components/calendar_month_view.dart';
import '../viewmodels/calendar_viewmodel.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(),
      child: Container(
        color: Colors.transparent,
        // --- Stack requis : FloatingNavMenu se positionne via Positioned ---
        child: Stack(
          children: [
            const Column(
              children: [
                CalendarTopBar(),
                SizedBox(height: 8),
                CalendarMonthView(),
              ],
            ),

            // --- Menu de navigation flottant, bas-droite ---
            const FloatingNavMenu(currentRoute: AppRoutes.calendar),
          ],
        ),
      ),
    );
  }
}