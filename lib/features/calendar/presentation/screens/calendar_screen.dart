// ============================================================================
// CALENDAR SCREEN
// ============================================================================
// Calendrier "parchemin" : tous les mois défilent dans une seule liste, du
// plus ancien en haut au mois en cours en bas. L'en-tête fixe affiche le
// mois qui touche le haut de l'écran.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../../../navigation/presentation/components/floating_nav_menu.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../../domain/entities/calendar_month.dart';
import '../components/calendar_header.dart';
import '../components/calendar_month_list.dart';
import '../components/calendar_month_picker_sheet.dart';
import '../models/calendar_layout.dart';
import '../viewmodels/calendar_viewmodel.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(
        watchTimelineEvents: sl.watchTimelineEvents,
        groupEventsByDay: sl.groupEventsByDay,
      ),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatefulWidget {
  const _CalendarView();

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  // --- Pur état d'interface : le défilement et la géométrie de la liste ---
  final ScrollController _scrollController = ScrollController();
  CalendarLayout? _layout;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --- La géométrie ne dépend que de la largeur : on la garde tant que
  // --- celle-ci ne change pas ---
  CalendarLayout _layoutFor(double width, CalendarViewModel viewModel) {
    final current = _layout;
    if (current != null && current.width == width) return current;

    final layout = CalendarLayout(
      width: width,
      lastMonth: viewModel.lastMonth,
      monthCount: viewModel.monthCount,
    );
    _layout = layout;

    // --- L'en-tête doit refléter la position une fois la liste posée ---
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncVisibleMonth());
    return layout;
  }

  void _onScroll() {
    // --- Si le défilement bouge pendant la construction de l'écran, on
    // --- attend la fin de l'image pour prévenir le ViewModel ---
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncVisibleMonth());
    } else {
      _syncVisibleMonth();
    }
  }

  // --- Indique au ViewModel quel mois touche le haut de la liste ---
  void _syncVisibleMonth() {
    final layout = _layout;
    if (!mounted || layout == null || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (!position.hasPixels || !position.hasViewportDimension) return;

    context.read<CalendarViewModel>().showMonthAt(
          layout.topMonthIndex(
            scrollOffset: position.pixels,
            viewportHeight: position.viewportDimension,
          ),
        );
  }

  // --- Tap sur le mois de l'en-tête : on choisit un mois, puis on y saute ---
  Future<void> _openMonthPicker(CalendarViewModel viewModel) async {
    final picked = await showModalBottomSheet<CalendarMonth>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CalendarMonthPickerSheet(
        selected: viewModel.visibleMonth,
        firstMonth: viewModel.firstMonth,
        lastMonth: viewModel.lastMonth,
      ),
    );

    if (picked == null || !mounted) return;
    _jumpToMonth(viewModel.indexOf(picked));
  }

  void _jumpToMonth(int index) {
    final layout = _layout;
    if (layout == null || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    _scrollController.jumpTo(
      layout.scrollOffsetForMonth(
        index: index,
        viewportHeight: position.viewportDimension,
        maxScrollExtent: position.maxScrollExtent,
      ),
    );
  }

  // --- Tap sur une case avec souvenir. Le détail est empilé : son bouton
  // --- retour ramène donc ici, sur le calendrier ---
  void _openEvents(List<TimelineEventEntity> events) {
    if (events.isEmpty) return;
    context.push(AppRoutes.timelineDetailPath(events.first.id));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();

    // --- Material requis : l'écran n'a pas de Scaffold, or ses textes et
    // --- ses InkWell ont besoin d'un ancêtre Material ---
    return Material(
      type: MaterialType.transparency,
      // --- Stack requis : FloatingNavMenu se positionne via Positioned ---
      child: Stack(
        children: [
          Column(
            children: [
              CalendarHeader(
                month: viewModel.visibleMonth,
                onMonthTap: () => _openMonthPicker(viewModel),
                onAddTap: () => context.push(AppRoutes.addTimeline),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CalendarMonthList(
                      controller: _scrollController,
                      layout: _layoutFor(constraints.maxWidth, viewModel),
                      visibleMonth: viewModel.visibleMonth,
                      today: viewModel.today,
                      eventsOn: viewModel.eventsOn,
                      onEventsTap: _openEvents,
                    );
                  },
                ),
              ),
            ],
          ),

          // --- Menu de navigation flottant, bas-droite ---
          const FloatingNavMenu(currentRoute: AppRoutes.calendar),
        ],
      ),
    );
  }
}
