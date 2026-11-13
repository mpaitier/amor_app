// ============================================================================
// SETTINGS VIEWMODEL
// ============================================================================
// Détient les réglages du couple, suivis en temps réel, et enregistre
// chaque changement aussitôt fait : l'écran n'a pas de bouton "Enregistrer".

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/couple_settings_entity.dart';
import '../../domain/entities/special_day_style.dart';
import '../../domain/usecases/save_couple_settings.dart';
import '../../domain/usecases/watch_couple_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  final WatchCoupleSettings _watchCoupleSettings;
  final SaveCoupleSettings _saveCoupleSettings;

  StreamSubscription<CoupleSettingsEntity>? _subscription;

  // --- Aujourd'hui, sans heure : sert aux aperçus ---
  final DateTime today;

  // --- State ---
  CoupleSettingsEntity? _settings;
  String? _errorMessage;

  SettingsViewModel({
    required WatchCoupleSettings watchCoupleSettings,
    required SaveCoupleSettings saveCoupleSettings,
    DateTime? now,
  })  : _watchCoupleSettings = watchCoupleSettings,
        _saveCoupleSettings = saveCoupleSettings,
        today = _dayOf(now ?? DateTime.now()) {
    _listenToSettings();
  }

  static DateTime _dayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- Getters ---
  bool get isLoading => _settings == null;
  String? get errorMessage => _errorMessage;
  CoupleSettingsEntity get settings =>
      _settings ?? CoupleSettingsEntity.defaults();

  // --- Prochain anniversaire et son rang, pour l'aperçu ---
  DateTime get nextAnniversary => settings.nextAnniversary(today);
  int get nextAnniversaryNumber =>
      settings.anniversaryNumberOn(nextAnniversary) ?? 1;

  // --- Prochain mois-anniversaire et son rang, pour l'aperçu ---
  DateTime get nextMonthAnniversary => settings.nextMonthAnniversary(today);
  int get nextMonthAnniversaryNumber =>
      settings.monthAnniversaryNumberOn(nextMonthAnniversary) ?? 1;

  // --- Setters : chacun enregistre aussitôt ---
  Future<void> setRelationshipStart(DateTime date) {
    return _update(settings.copyWith(relationshipStart: _dayOf(date)));
  }

  Future<void> setShowAnniversary(bool value) {
    return _update(settings.copyWith(showAnniversary: value));
  }

  Future<void> setAnniversaryStyle(SpecialDayStyle style) {
    return _update(settings.copyWith(anniversaryStyle: style));
  }

  Future<void> setShowMonthAnniversaries(bool value) {
    return _update(settings.copyWith(showMonthAnniversaries: value));
  }

  Future<void> setMonthAnniversaryStyle(SpecialDayStyle style) {
    return _update(settings.copyWith(monthAnniversaryStyle: style));
  }

  // --- Un terme vide reprend celui d'origine ; un terme inchangé n'est
  // --- pas réenregistré ---
  Future<void> setGifSearchTerm(String term) async {
    final trimmed = term.trim();
    final value =
        trimmed.isEmpty ? CoupleSettingsEntity.defaultGifSearchTerm : trimmed;
    if (value == settings.gifSearchTerm) return;
    await _update(settings.copyWith(gifSearchTerm: value));
  }

  // --- Affiche le changement tout de suite, puis l'enregistre ---
  Future<void> _update(CoupleSettingsEntity updated) async {
    _settings = updated;
    _errorMessage = null;
    notifyListeners();

    try {
      await _saveCoupleSettings(updated);
    } catch (e) {
      _errorMessage = 'Enregistrement impossible : $e';
      notifyListeners();
    }
  }

  void _listenToSettings() {
    _subscription = _watchCoupleSettings().listen((settings) {
      _settings = settings;
      notifyListeners();
    }, onError: (Object error) {
      _errorMessage = 'Impossible de charger les paramètres : $error';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
