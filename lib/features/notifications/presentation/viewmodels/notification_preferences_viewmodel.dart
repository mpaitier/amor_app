// ============================================================================
// NOTIFICATION PREFERENCES VIEWMODEL
// ============================================================================
// Préférences de notifications de ce téléphone, suivies en temps réel et
// enregistrées à chaque changement.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/usecases/save_notification_preferences.dart';
import '../../domain/usecases/watch_notification_preferences.dart';

class NotificationPreferencesViewModel extends ChangeNotifier {
  // --- Bornes du rappel ---
  static const int minReminderDays = 1;
  static const int maxReminderDays = 60;

  final WatchNotificationPreferences _watchPreferences;
  final SaveNotificationPreferences _savePreferences;

  StreamSubscription<NotificationPreferences>? _subscription;

  // --- State ---
  NotificationPreferences? _preferences;
  String? _errorMessage;

  NotificationPreferencesViewModel({
    required WatchNotificationPreferences watchPreferences,
    required SaveNotificationPreferences savePreferences,
  })  : _watchPreferences = watchPreferences,
        _savePreferences = savePreferences {
    _listen();
  }

  // --- Getters ---
  bool get isLoading => _preferences == null;
  String? get errorMessage => _errorMessage;
  NotificationPreferences get preferences =>
      _preferences ?? const NotificationPreferences();

  // --- Setters : chacun enregistre aussitôt ---
  Future<void> setEnabled(bool value) =>
      _update(preferences.copyWith(enabled: value));

  Future<void> setNewMemory(bool value) =>
      _update(preferences.copyWith(newMemory: value));

  Future<void> setImportantDates(bool value) =>
      _update(preferences.copyWith(importantDates: value));

  Future<void> setAnniversaries(bool value) =>
      _update(preferences.copyWith(anniversaries: value));

  Future<void> setDayOfTime(int minutes) =>
      _update(preferences.copyWith(dayOfTime: minutes));

  Future<void> setReminderEnabled(bool value) =>
      _update(preferences.copyWith(reminderEnabled: value));

  Future<void> setReminderDaysBefore(int days) {
    final clamped = days.clamp(minReminderDays, maxReminderDays);
    return _update(preferences.copyWith(reminderDaysBefore: clamped));
  }

  Future<void> setReminderTime(int minutes) =>
      _update(preferences.copyWith(reminderTime: minutes));

  // --- Affiche le changement tout de suite, puis l'enregistre ---
  Future<void> _update(NotificationPreferences updated) async {
    _preferences = updated;
    _errorMessage = null;
    notifyListeners();

    try {
      await _savePreferences(updated);
    } catch (e) {
      _errorMessage = 'Enregistrement impossible : $e';
      notifyListeners();
    }
  }

  void _listen() {
    _subscription = _watchPreferences().listen((preferences) {
      _preferences = preferences;
      notifyListeners();
    }, onError: (Object error) {
      _errorMessage = 'Impossible de charger les notifications : $error';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
