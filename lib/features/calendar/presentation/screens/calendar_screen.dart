// ============================================================================
// CALENDAR SCREEN
// ============================================================================
// Calendrier "parchemin" : tous les mois défilent dans une seule liste, du
// plus ancien en haut au dernier en bas. Le dernier mois est le mois en
// cours, ou plus loin s'il existe une date importante à venir. L'en-tête
// fixe affiche le mois qui touche le haut de l'écran.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/add_entry_flow.dart';
import '../../../../navigation/app_routes.dart';
import '../../../important_dates/domain/entities/important_date_entity.dart';
import '../../../important_dates/presentation/components/delete_important_date_dialog.dart';
import '../../../important_dates/presentation/components/important_date_sheet.dart';
import '../../../navigation/presentation/components/floating_nav_menu.dart';
import '../../../timeline/domain/entities/timeline_event_entity.dart';
import '../../domain/entities/calendar_month.dart';
import '../components/calendar_day_sheet.dart';
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
        watchImportantDates: sl.watchImportantDates,
        deleteImportantDate: sl.deleteImportantDate,
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
  // --- Forme commune aux panneaux ouverts depuis le bas de l'écran ---
  static const ShapeBorder _sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  );

  // --- Pur état d'interface : le défilement et la géométrie de la liste.
  // --- Le contrôleur naît avec la première géométrie, car sa position de
  // --- départ en dépend ---
  ScrollController? _scrollController;
  CalendarLayout? _layout;

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    super.dispose();
  }

  // --- La géométrie dépend de la largeur et de la plage de mois : on la
  // --- garde tant qu'aucune des deux ne change ---
  CalendarLayout _layoutFor(double width, CalendarViewModel viewModel) {
    final previous = _layout;
    if (previous != null &&
        previous.width == width &&
        previous.lastMonth == viewModel.lastMonth &&
        previous.monthCount == viewModel.monthCount) {
      return previous;
    }

    final layout = CalendarLayout(
      width: width,
      lastMonth: viewModel.lastMonth,
      monthCount: viewModel.monthCount,
    );
    _layout = layout;

    if (previous != null) _keepPositionAfterRangeChange(previous, layout);

    // --- L'en-tête doit refléter la position une fois la liste posée ---
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncVisibleMonth());
    return layout;
  }

  // --- À l'ouverture, le mois en cours est posé en bas de l'écran. Les
  // --- mois à venir, s'il y en a, se découvrent en défilant vers le bas ---
  ScrollController _controllerFor(
    CalendarLayout layout,
    CalendarViewModel viewModel,
  ) {
    final existing = _scrollController;
    if (existing != null) return existing;

    final controller = ScrollController(
      initialScrollOffset: layout.monthStart(viewModel.currentMonthIndex),
    );
    controller.addListener(_onScroll);
    _scrollController = controller;
    return controller;
  }

  // --- La liste est mesurée depuis son bas. Quand des mois s'ajoutent ou
  // --- disparaissent à cet endroit (date importante créée ou supprimée),
  // --- tout le contenu se décale : on corrige la position d'autant pour
  // --- que l'écran continue de montrer les mêmes jours ---
  void _keepPositionAfterRangeChange(
    CalendarLayout previous,
    CalendarLayout next,
  ) {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;

    final addedMonths = previous.lastMonth.monthsUntil(next.lastMonth);
    if (addedMonths == 0) return;

    final correction = addedMonths > 0
        ? next.monthStart(addedMonths)
        : -previous.monthStart(-addedMonths);
    controller.position.correctBy(correction);
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
    final controller = _scrollController;
    if (!mounted || layout == null || controller == null) return;
    if (!controller.hasClients) return;

    final position = controller.position;
    if (!position.hasPixels || !position.hasViewportDimension) return;

    final index = layout.topMonthIndex(
      scrollOffset: position.pixels,
      viewportHeight: position.viewportDimension,
    );
    context.read<CalendarViewModel>().showMonth(layout.monthAt(index));
  }

  // --- Tap sur le mois de l'en-tête : on choisit un mois, puis on y saute ---
  Future<void> _openMonthPicker(CalendarViewModel viewModel) async {
    final picked = await showModalBottomSheet<CalendarMonth>(
      context: context,
      backgroundColor: Colors.white,
      shape: _sheetShape,
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
    final controller = _scrollController;
    if (layout == null || controller == null || !controller.hasClients) return;

    final position = controller.position;
    controller.jumpTo(
      layout.scrollOffsetForMonth(
        index: index,
        viewportHeight: position.viewportDimension,
        maxScrollExtent: position.maxScrollExtent,
      ),
    );
  }

  // --- Tap sur une case occupée. Un seul élément : on l'ouvre directement.
  // --- Plusieurs : on les liste d'abord ---
  Future<void> _openDay(DateTime day) async {
    final viewModel = context.read<CalendarViewModel>();
    final memories = viewModel.eventsOn(day);
    final importantDates = viewModel.importantDatesOn(day);

    if (memories.isEmpty && importantDates.isEmpty) return;

    if (memories.length + importantDates.length == 1) {
      if (memories.isNotEmpty) {
        _openMemory(memories.first);
      } else {
        await _openImportantDate(viewModel, importantDates.first, day);
      }
      return;
    }

    final picked = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: Colors.white,
      shape: _sheetShape,
      builder: (_) => CalendarDaySheet(
        day: day,
        memories: memories,
        importantDates: importantDates,
      ),
    );

    if (picked == null || !mounted) return;
    if (picked is TimelineEventEntity) {
      _openMemory(picked);
    } else if (picked is ImportantDateEntity) {
      await _openImportantDate(viewModel, picked, day);
    }
  }

  // --- Le détail est empilé : son bouton retour ramène donc ici ---
  void _openMemory(TimelineEventEntity memory) {
    context.push(AppRoutes.timelineDetailPath(memory.id));
  }

  // --- Fiche d'une date importante, puis l'action choisie dedans ---
  Future<void> _openImportantDate(
    CalendarViewModel viewModel,
    ImportantDateEntity date,
    DateTime occurrence,
  ) async {
    final action = await showModalBottomSheet<ImportantDateAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: _sheetShape,
      builder: (_) => ImportantDateSheet(
        date: date,
        occurrence: occurrence,
        today: viewModel.today,
      ),
    );

    if (action == null || !mounted) return;
    if (action == ImportantDateAction.edit) {
      context.push(AppRoutes.addImportantDate, extra: {'dateToEdit': date});
    } else {
      await _deleteImportantDate(viewModel, date);
    }
  }

  // --- Confirmation, puis suppression ---
  Future<void> _deleteImportantDate(
    CalendarViewModel viewModel,
    ImportantDateEntity date,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteImportantDateDialog(dateTitle: date.title),
    );
    if (confirmed != true) return;

    final deleted = await viewModel.deleteImportantDate(date.id);
    if (deleted || !mounted) return;
    _showError(viewModel.errorMessage ?? 'La suppression a échoué.');
  }

  // --- Une boîte de dialogue plutôt qu'un SnackBar : l'écran n'a pas de
  // --- Scaffold pour en afficher un ---
  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                onAddTap: () => openAddEntryFlow(context),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final layout = _layoutFor(constraints.maxWidth, viewModel);
                    return CalendarMonthList(
                      controller: _controllerFor(layout, viewModel),
                      layout: layout,
                      visibleMonth: viewModel.visibleMonth,
                      today: viewModel.today,
                      eventsOn: viewModel.eventsOn,
                      importantDatesOn: viewModel.importantDatesOn,
                      onDayTap: _openDay,
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
