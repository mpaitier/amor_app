// ============================================================================
// SETTINGS VIEWMODEL
// ============================================================================
// Détient les réglages du couple, suivis en temps réel, et enregistre
// chaque changement aussitôt fait : l'écran n'a pas de bouton "Enregistrer".

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/couple_settings_entity.dart';
import '../../domain/entities/special_day_style.dart';
import '../../../gif/domain/usecases/get_random_gif.dart';
import '../../domain/usecases/save_couple_settings.dart';
import '../../domain/usecases/watch_couple_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  final WatchCoupleSettings _watchCoupleSettings;
  final SaveCoupleSettings _saveCoupleSettings;
  final GetRandomGif _getRandomGif;

  StreamSubscription<CoupleSettingsEntity>? _subscription;

  // --- Aujourd'hui, sans heure : sert aux aperçus ---
  final DateTime today;

  // --- State ---
  CoupleSettingsEntity? _settings;
  String? _errorMessage;
  bool _isAnniversaryGifLoading = false;
  bool _isMonthAnniversaryGifLoading = false;
  bool _isDisposed = false;

  SettingsViewModel({
    required WatchCoupleSettings watchCoupleSettings,
    required SaveCoupleSettings saveCoupleSettings,
    required GetRandomGif getRandomGif,
    DateTime? now,
  })  : _watchCoupleSettings = watchCoupleSettings,
        _saveCoupleSettings = saveCoupleSettings,
        _getRandomGif = getRandomGif,
        today = _dayOf(now ?? DateTime.now()) {
    _listenToSettings();
  }

  static DateTime _dayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- Getters ---
  bool get isLoading => _settings == null;
  String? get errorMessage => _errorMessage;
  bool get isAnniversaryGifLoading => _isAnniversaryGifLoading;
  bool get isMonthAnniversaryGifLoading => _isMonthAnniversaryGifLoading;
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

  // --- À la première activation, un GIF est tiré ---
  Future<void> setShowAnniversary(bool value) async {
    await _update(settings.copyWith(showAnniversary: value));
    if (value && settings.anniversaryStyle.gifUrl.isEmpty) {
      await drawAnniversaryGif();
    }
  }

  Future<void> setAnniversaryStyle(SpecialDayStyle style) {
    return _update(settings.copyWith(anniversaryStyle: style));
  }

  // --- À la première activation, un GIF est tiré ---
  Future<void> setShowMonthAnniversaries(bool value) async {
    await _update(settings.copyWith(showMonthAnniversaries: value));
    if (value && settings.monthAnniversaryStyle.gifUrl.isEmpty) {
      await drawMonthAnniversaryGif();
    }
  }

  // --- Tire un GIF pour l'anniversaire, avec le terme des paramètres ---
  Future<void> drawAnniversaryGif() async {
    _isAnniversaryGifLoading = true;
    notifyListeners();

    final url = await _getRandomGif(settings.gifSearchTerm);
    if (_isDisposed) return;
    _isAnniversaryGifLoading = false;

    // --- En cas d'échec, on garde le GIF précédent ---
    if (url == null) {
      notifyListeners();
      return;
    }
    await _update(
      settings.copyWith(
        anniversaryStyle: settings.anniversaryStyle.copyWith(gifUrl: url),
      ),
    );
  }

  // --- Tire un GIF pour les mois-anniversaires ---
  Future<void> drawMonthAnniversaryGif() async {
    _isMonthAnniversaryGifLoading = true;
    notifyListeners();

    final url = await _getRandomGif(settings.gifSearchTerm);
    if (_isDisposed) return;
    _isMonthAnniversaryGifLoading = false;

    if (url == null) {
      notifyListeners();
      return;
    }
    await _update(
      settings.copyWith(
        monthAnniversaryStyle:
            settings.monthAnniversaryStyle.copyWith(gifUrl: url),
      ),
    );
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
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
