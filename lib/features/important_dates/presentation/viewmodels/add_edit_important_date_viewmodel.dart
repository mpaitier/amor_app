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

  // --- Contrôleur de texte, détenu et libéré par le ViewModel ---
  final TextEditingController titleController;

  // --- Form state ---
  DateTime selectedDate;
  String selectedEmoji;
  bool repeatsYearly;
  int backgroundColor;
  int borderColor;

  // --- Technical state ---
  bool isSaving = false;
  String? errorMessage;

  bool get isEditing => dateToEdit != null;

  AddEditImportantDateViewModel({
    required AddImportantDate addImportantDate,
    required UpdateImportantDate updateImportantDate,
    this.dateToEdit,
    DateTime? initialDate,
  })  : _addImportantDate = addImportantDate,
        _updateImportantDate = updateImportantDate,
        titleController = TextEditingController(text: dateToEdit?.title ?? ''),
        selectedDate = _dayOf(dateToEdit?.date ?? initialDate ?? DateTime.now()),
        selectedEmoji = dateToEdit?.emoji ?? ImportantDatePalette.emojis.first,
        repeatsYearly = dateToEdit?.repeatsYearly ?? false,
        backgroundColor = dateToEdit?.backgroundColor ??
            ImportantDateEntity.defaultBackgroundColor,
        borderColor =
            dateToEdit?.borderColor ?? ImportantDateEntity.defaultBorderColor;

  // --- Ne garde que le jour : une date importante n'a pas d'heure ---
  static DateTime _dayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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

  void setRepeatsYearly(bool value) {
    repeatsYearly = value;
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
    final title = titleController.text.trim();
    if (title.isEmpty) {
      errorMessage = 'Donne un titre à cette date';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final date = ImportantDateEntity(
        id: dateToEdit?.id ?? '',
        title: title,
        date: selectedDate,
        emoji: selectedEmoji,
        repeatsYearly: repeatsYearly,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
      );

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
