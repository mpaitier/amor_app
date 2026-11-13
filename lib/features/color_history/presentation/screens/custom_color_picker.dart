// ============================================================================
// CUSTOM COLOR PICKER
// ============================================================================
// Ouvre le sélecteur de couleur libre avec son ViewModel. Renvoie la couleur
// choisie (entier ARGB), ou null si on annule.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../components/color_picker_dialog.dart';
import '../viewmodels/color_picker_viewmodel.dart';

Future<int?> showCustomColorPicker(
  BuildContext context, {
  required int initialColor,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => ColorPickerViewModel(
        getRecentColors: sl.getRecentColors,
        addRecentColor: sl.addRecentColor,
        initialColor: initialColor,
      ),
      child: const ColorPickerDialog(),
    ),
  );
}
