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
  ImportantDateRecurrence recurrence;
  int backgroundColor;
  int borderColor;

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
        recurrence = dateToEdit?.recurrence ?? ImportantDateRecurrence.none,
        backgroundColor = dateToEdit?.backgroundColor ??
            ImportantDateEntity.defaultBackgroundColor,
        borderColor =
            dateToEdit?.borderColor ?? ImportantDateEntity.defaultBorderColor;

  // --- Ne garde que le jour : une date importante n'a pas d'heure ---
  static DateTime _dayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- Getters ---
  bool get isEditing => dateToEdit != null;
  bool get repeats => recurrence != ImportantDateRecurrence.none;

  // --- La date telle que le formulaire la décrit en ce moment. Sert à
  // --- l'aperçu, puis à l'enregistrement ---
  ImportantDateEntity get draft {
    return ImportantDateEntity(
      id: dateToEdit?.id ?? '',
      title: titleController.text.trim(),
      date: selectedDate,
      emoji: selectedEmoji,
      recurrence: recurrence,
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

  // --- Active ou coupe la répétition. Activée, elle part sur la première
  // --- fréquence proposée : tous les ans ---
  void setRepeats(bool value) {
    recurrence = value
        ? ImportantDatePalette.recurrences.first
        : ImportantDateRecurrence.none;
    notifyListeners();
  }

  void setRecurrence(ImportantDateRecurrence value) {
    recurrence = value;
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
