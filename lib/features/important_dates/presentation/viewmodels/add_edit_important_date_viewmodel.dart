// ============================================================================
// ADD / EDIT IMPORTANT DATE VIEWMODEL
// ============================================================================
// Détient l'état du formulaire d'une date importante et l'enregistre,
// en création comme en modification.

import 'package:flutter/material.dart';
import '../../domain/entities/important_date_entity.dart';
import '../../domain/usecases/add_important_date.dart';
import '../../domain/usecases/update_important_date.dart';
import '../../../gif/domain/usecases/get_random_gif.dart';
import '../../../settings/domain/usecases/get_gif_search_term.dart';
import '../models/important_date_palette.dart';
import '../models/recurrence_rule.dart';

class AddEditImportantDateViewModel extends ChangeNotifier {
  final AddImportantDate _addImportantDate;
  final UpdateImportantDate _updateImportantDate;
  final GetRandomGif _getRandomGif;
  final GetGifSearchTerm _getGifSearchTerm;

  final ImportantDateEntity? dateToEdit;

  // --- Aujourd'hui, sans heure : sert au compte à rebours de l'aperçu ---
  final DateTime today;

  // --- Contrôleur de texte, détenu et libéré par le ViewModel ---
  final TextEditingController titleController;

  // --- Form state ---
  DateTime selectedDate;
  String selectedEmoji;
  int backgroundColor;
  int borderColor;

  // --- Répétition. La fréquence et la limite sont gardées même quand la
  // --- répétition est coupée : le libellé grisé les montre, et elles
  // --- reviennent telles quelles si on la réactive ---
  bool repeats;
  ImportantDateRecurrence recurrence;
  int? occurrenceLimit;

  // --- GIF de la date : repris à la modification, tiré au hasard sinon ---
  String gifUrl;
  bool isGifLoading = false;

  // --- Technical state ---
  bool isSaving = false;
  String? errorMessage;
  bool _isDisposed = false;

  AddEditImportantDateViewModel({
    required AddImportantDate addImportantDate,
    required UpdateImportantDate updateImportantDate,
    required GetRandomGif getRandomGif,
    required GetGifSearchTerm getGifSearchTerm,
    this.dateToEdit,
    DateTime? initialDate,
    DateTime? now,
  })  : _addImportantDate = addImportantDate,
        _updateImportantDate = updateImportantDate,
        _getRandomGif = getRandomGif,
        _getGifSearchTerm = getGifSearchTerm,
        gifUrl = dateToEdit?.gifUrl ?? '',
        today = _dayOf(now ?? DateTime.now()),
        titleController = TextEditingController(text: dateToEdit?.title ?? ''),
        selectedDate =
            _dayOf(dateToEdit?.date ?? initialDate ?? now ?? DateTime.now()),
        selectedEmoji = dateToEdit?.emoji ?? ImportantDatePalette.emojis.first,
        backgroundColor = dateToEdit?.backgroundColor ??
            ImportantDateEntity.defaultBackgroundColor,
        borderColor =
            dateToEdit?.borderColor ?? ImportantDateEntity.defaultBorderColor,
        repeats = dateToEdit?.repeats ?? false,
        recurrence = (dateToEdit?.repeats ?? false)
            ? dateToEdit!.recurrence
            : ImportantDatePalette.recurrences.first,
        occurrenceLimit =
            (dateToEdit?.repeats ?? false) ? dateToEdit!.occurrenceLimit : null {
    if (gifUrl.isEmpty) loadRandomGif();
  }

  // --- Ne garde que le jour : une date importante n'a pas d'heure ---
  static DateTime _dayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- Getters ---
  bool get isEditing => dateToEdit != null;

  // --- La date telle que le formulaire la décrit en ce moment. Sert à
  // --- l'aperçu, puis à l'enregistrement ---
  ImportantDateEntity get draft {
    return ImportantDateEntity(
      id: dateToEdit?.id ?? '',
      title: titleController.text.trim(),
      date: selectedDate,
      emoji: selectedEmoji,
      recurrence: repeats ? recurrence : ImportantDateRecurrence.none,
      occurrenceLimit: repeats ? occurrenceLimit : null,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      gifUrl: gifUrl,
    );
  }

  // --- Field setters ---
  void setDate(DateTime date) {
    selectedDate = _dayOf(date);
    notifyListeners();
  }

  void setEmoji(String emoji) {
    selectedEmoji = emoji;
    notifyListeners();
  }

  void setRepeats(bool value) {
    repeats = value;
    notifyListeners();
  }

  // --- Règle choisie dans la boîte de dialogue de répétition ---
  void setRecurrenceRule(RecurrenceRule rule) {
    if (rule.recurrence == ImportantDateRecurrence.none) return;
    recurrence = rule.recurrence;
    occurrenceLimit = rule.occurrenceLimit;
    notifyListeners();
  }

  // --- Tire un nouveau GIF au hasard, avec le terme des paramètres ---
  Future<void> loadRandomGif() async {
    isGifLoading = true;
    notifyListeners();

    final searchTerm = await _getGifSearchTerm();
    if (_isDisposed) return;
    final url = await _getRandomGif(searchTerm);
    if (_isDisposed) return;

    // --- En cas d'échec, on garde le GIF précédent ---
    if (url != null) gifUrl = url;
    isGifLoading = false;
    notifyListeners();
  }

  void setBackgroundColor(int color) {
    backgroundColor = color;
    notifyListeners();
  }

  void setBorderColor(int color) {
    borderColor = color;
    notifyListeners();
  }

  // --- Enregistre la date. Renvoie true si elle a bien été sauvegardée ---
  Future<bool> save() async {
    final date = draft;
    if (date.title.isEmpty) {
      errorMessage = 'Donne un titre à cette date';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (isEditing) {
        await _updateImportantDate(date);
      } else {
        await _addImportantDate(date);
      }
      return true;
    } catch (e) {
      errorMessage = 'Enregistrement impossible : $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    titleController.dispose();
    super.dispose();
  }
}
