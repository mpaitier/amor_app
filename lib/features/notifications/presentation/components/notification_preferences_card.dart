// ============================================================================
// NOTIFICATION PREFERENCES CARD
// ============================================================================
// Réglages de notifications de ce téléphone : l'interrupteur général, un
// interrupteur par type, l'heure du jour J et le rappel. Tout est grisé
// quand l'interrupteur général est coupé.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../important_dates/presentation/components/occurrence_limit_stepper.dart';
import '../viewmodels/notification_preferences_viewmodel.dart';
import 'notification_switch_tile.dart';
import 'notification_time_tile.dart';

class NotificationPreferencesCard extends StatelessWidget {
  const NotificationPreferencesCard({super.key});

  static const double _indent = 12;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationPreferencesViewModel>();

    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(color: amorPink)),
      );
    }

    final preferences = viewModel.preferences;
    final enabled = preferences.enabled;
    final timingEnabled = preferences.notifiesSpecialDays;
    final reminderEnabled = timingEnabled && preferences.reminderEnabled;
    final days = preferences.reminderDaysBefore;

    // --- Un réglage dépendant d'un interrupteur coupé n'est pas modifiable ---
    T? onlyIf<T>(bool condition, T value) => condition ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: errorLight),
            ),
          ),
        NotificationSwitchTile(
          title: 'Activer les notifications',
          subtitle: 'Sur ce téléphone',
          value: enabled,
          onChanged: viewModel.setEnabled,
        ),
        const Divider(height: 20),
        NotificationSwitchTile(
          title: 'Nouveau souvenir',
          value: preferences.newMemory,
          onChanged: onlyIf(enabled, viewModel.setNewMemory),
          indent: _indent,
        ),
        NotificationSwitchTile(
          title: 'Dates importantes',
          value: preferences.importantDates,
          onChanged: onlyIf(enabled, viewModel.setImportantDates),
          indent: _indent,
        ),
        NotificationSwitchTile(
          title: 'Anniversaires',
          subtitle: 'Ceux affichés dans le calendrier',
          value: preferences.anniversaries,
          onChanged: onlyIf(enabled, viewModel.setAnniversaries),
          indent: _indent,
        ),
        const Divider(height: 20),

        // --- Heure du jour J, commune aux dates et aux anniversaires ---
        NotificationTimeTile(
          label: 'Le jour même',
          minutes: preferences.dayOfTime,
          onChanged: onlyIf(timingEnabled, viewModel.setDayOfTime),
          indent: _indent,
        ),
        NotificationSwitchTile(
          title: 'Rappel avant',
          value: preferences.reminderEnabled,
          onChanged: onlyIf(timingEnabled, viewModel.setReminderEnabled),
          indent: _indent,
        ),
        if (preferences.reminderEnabled) ...[
          IgnorePointer(
            ignoring: !reminderEnabled,
            child: Opacity(
              opacity: reminderEnabled ? 1 : 0.4,
              child: OccurrenceLimitStepper(
                value: days,
                min: NotificationPreferencesViewModel.minReminderDays,
                max: NotificationPreferencesViewModel.maxReminderDays,
                unit: days > 1 ? 'jours avant' : 'jour avant',
                onChanged: viewModel.setReminderDaysBefore,
              ),
            ),
          ),
          NotificationTimeTile(
            label: 'Heure du rappel',
            minutes: preferences.reminderTime,
            onChanged: onlyIf(reminderEnabled, viewModel.setReminderTime),
            indent: _indent * 2,
          ),
        ],
      ],
    );
  }
}
