// ============================================================================
// IMPORTANT DATE RECURRENCE DIALOG
// ============================================================================
// Choix de la fréquence, puis d'un éventuel arrêt après un nombre de fois.
// Se ferme en renvoyant la RecurrenceRule retenue, ou null si on annule.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/important_date_palette.dart';
import '../models/recurrence_rule.dart';
import '../utils/important_date_labels.dart';
import 'occurrence_limit_stepper.dart';

class ImportantDateRecurrenceDialog extends StatefulWidget {
  final RecurrenceRule initialRule;

  const ImportantDateRecurrenceDialog({super.key, required this.initialRule});

  @override
  State<ImportantDateRecurrenceDialog> createState() =>
      _ImportantDateRecurrenceDialogState();
}

class _ImportantDateRecurrenceDialogState
    extends State<ImportantDateRecurrenceDialog> {
  // --- Bornes du nombre de fois : moins de 2, ce n'est plus une répétition ---
  static const int _minLimit = 2;
  static const int _maxLimit = 999;
  static const int _defaultLimit = 5;

  // --- Pur état d'interface, renvoyé seulement si on valide ---
  late var _recurrence = widget.initialRule.recurrence;
  late var _hasLimit = widget.initialRule.occurrenceLimit != null;
  late var _limit = widget.initialRule.occurrenceLimit ?? _defaultLimit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Répétition'),
      contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final recurrence in ImportantDatePalette.recurrences)
              ListTile(
                title: Text(recurrenceLabel(recurrence)),
                trailing: recurrence == _recurrence
                    ? const Icon(Icons.check, color: amorDarkRose)
                    : null,
                onTap: () => setState(() => _recurrence = recurrence),
              ),
            const Divider(),
            SwitchListTile(
              title: const Text('Arrêter après'),
              value: _hasLimit,
              onChanged: (value) => setState(() => _hasLimit = value),
            ),
            if (_hasLimit)
              OccurrenceLimitStepper(
                value: _limit,
                min: _minLimit,
                max: _maxLimit,
                unit: occurrenceUnitLabel(_recurrence, _limit),
                onChanged: (value) => setState(() => _limit = value),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            RecurrenceRule(
              recurrence: _recurrence,
              occurrenceLimit: _hasLimit ? _limit : null,
            ),
          ),
          child: const Text(
            'OK',
            style: TextStyle(color: amorDarkRose, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
