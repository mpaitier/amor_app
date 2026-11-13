// ============================================================================
// UPCOMING SPECIAL DAYS VIEWMODEL
// ============================================================================
// Suit les réglages du couple pour annoncer dans le journal le prochain
// anniversaire et le prochain mois-anniversaire, s'ils sont affichés.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../settings/domain/entities/couple_settings_entity.dart';
import '../../../settings/domain/entities/upcoming_special_day.dart';
import '../../../settings/domain/usecases/get_upcoming_special_days.dart';
import '../../../settings/domain/usecases/watch_couple_settings.dart';

class UpcomingSpecialDaysViewModel extends ChangeNotifier {
  final WatchCoupleSettings _watchCoupleSettings;
  final GetUpcomingSpecialDays _getUpcomingSpecialDays;

  StreamSubscription<CoupleSettingsEntity>? _subscription;

  // --- Aujourd'hui, sans heure ---
  final DateTime today;

  // --- State ---
  List<UpcomingSpecialDay> _upcoming = const [];

  UpcomingSpecialDaysViewModel({
    required WatchCoupleSettings watchCoupleSettings,
    required GetUpcomingSpecialDays getUpcomingSpecialDays,
    DateTime? now,
  })  : _watchCoupleSettings = watchCoupleSettings,
        _getUpcomingSpecialDays = getUpcomingSpecialDays,
        today = _dayOf(now ?? DateTime.now()) {
    _listenToSettings();
  }

  static DateTime _dayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- Du plus proche au plus lointain ---
  List<UpcomingSpecialDay> get upcoming => _upcoming;

  void _listenToSettings() {
    _subscription = _watchCoupleSettings().listen((settings) {
      _upcoming = _getUpcomingSpecialDays(settings, today);
      notifyListeners();
    }, onError: (Object _) {
      // --- Sans réglages, le journal s'affiche simplement sans annonce ---
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
