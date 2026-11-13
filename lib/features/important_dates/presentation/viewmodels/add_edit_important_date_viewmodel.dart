// ============================================================================
// ADD / EDIT IMPORTANT DATE VIEWMODEL
// ============================================================================
// Détient l'état du formulaire d'une date importante et l'enregistre,
// en création comme en modification.

import 'package:flutter/material.dart';
import '../../domain/entities/important_date_entity.dart';
import '../../domain/usecases/add_important_date.dart';
import '../../domain/usecases/update_important_date.dart';
import '../models/important_date_palette.dart';
import '../models/recurrence_rule.dart';

class AddEditImportantDateViewModel extends ChangeNotifier {
  final AddImportantDate _addImportantDate;
  final UpdateImportantDate _updateImportantDate;

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

  // --- Technical state ---
  bool isSaving = false;
  String? errorMessage;

  AddEditImportantDateViewModel({
    required AddImportantDate addImportantDate,
    required UpdateImportantDate updateImportantDate,
    this.dateToEdit,
    DateTime? initialDate,
    DateTime? now,
  })  : _addImportantDate = addImportantDate,
        _updateImportantDate = updateImportantDate,
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
            (dateToEdit?.repeats ?? false) ? dateToEdit!.occurrenceLimit : null;

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
    titleController.dispose();
    super.dispose();
  }
}
