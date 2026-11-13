// ============================================================================
// NOTIFICATION PREFERENCES ENTITY
// ============================================================================
// Notifications que ce téléphone veut recevoir, et à quelle heure. Chaque
// téléphone a les siennes. Les heures sont en minutes depuis minuit (heure
// de Paris), sans dépendance à Flutter.

class NotificationPreferences {
  // --- Valeurs d'un téléphone qui n'a encore rien réglé ---
  static const int defaultDayOfTime = 9 * 60;
  static const int defaultReminderTime = 18 * 60;
  static const int defaultReminderDaysBefore = 1;

  // --- Interrupteur général : coupé, plus rien n'est envoyé ---
  final bool enabled;

  final bool newMemory;
  final bool importantDates;
  final bool anniversaries;

  // --- Heure de la notification du jour J ---
  final int dayOfTime;

  // --- Rappel "X jours avant à HH:MM" ---
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final int reminderTime;

  const NotificationPreferences({
    this.enabled = true,
    this.newMemory = true,
    this.importantDates = true,
    this.anniversaries = true,
    this.dayOfTime = defaultDayOfTime,
    this.reminderEnabled = false,
    this.reminderDaysBefore = defaultReminderDaysBefore,
    this.reminderTime = defaultReminderTime,
  });

  // --- Les jours spéciaux (dates importantes ou anniversaires) sont-ils
  // --- notifiés ? Sinon, les réglages d'heure et de rappel sont inutiles ---
  bool get notifiesSpecialDays => enabled && (importantDates || anniversaries);

  NotificationPreferences copyWith({
    bool? enabled,
    bool? newMemory,
    bool? importantDates,
    bool? anniversaries,
    int? dayOfTime,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    int? reminderTime,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      newMemory: newMemory ?? this.newMemory,
      importantDates: importantDates ?? this.importantDates,
      anniversaries: anniversaries ?? this.anniversaries,
      dayOfTime: dayOfTime ?? this.dayOfTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
