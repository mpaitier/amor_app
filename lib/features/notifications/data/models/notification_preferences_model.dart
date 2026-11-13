// ============================================================================
// NOTIFICATION PREFERENCES MODEL
// ============================================================================
// Convertit la map "notifications" du document device_tokens/{deviceId} en
// entité, et inversement. Les heures y sont écrites "HH:MM", lisibles dans
// la console Firebase et par la Cloud Function.

import '../../domain/entities/notification_preferences.dart';

class NotificationPreferencesModel extends NotificationPreferences {
  const NotificationPreferencesModel({
    super.enabled,
    super.newMemory,
    super.importantDates,
    super.anniversaries,
    super.dayOfTime,
    super.reminderEnabled,
    super.reminderDaysBefore,
    super.reminderTime,
  });

  // --- Un champ absent ou illisible reprend sa valeur d'origine ---
  factory NotificationPreferencesModel.fromMap(Map<String, dynamic>? data) {
    final map = data ?? const {};
    return NotificationPreferencesModel(
      enabled: map['enabled'] as bool? ?? true,
      newMemory: map['newMemory'] as bool? ?? true,
      importantDates: map['importantDates'] as bool? ?? true,
      anniversaries: map['anniversaries'] as bool? ?? true,
      dayOfTime: parseTime(map['dayOfTime']) ??
          NotificationPreferences.defaultDayOfTime,
      reminderEnabled: map['reminderEnabled'] as bool? ?? false,
      reminderDaysBefore: map['reminderDaysBefore'] as int? ??
          NotificationPreferences.defaultReminderDaysBefore,
      reminderTime: parseTime(map['reminderTime']) ??
          NotificationPreferences.defaultReminderTime,
    );
  }

  factory NotificationPreferencesModel.fromEntity(
    NotificationPreferences entity,
  ) {
    return NotificationPreferencesModel(
      enabled: entity.enabled,
      newMemory: entity.newMemory,
      importantDates: entity.importantDates,
      anniversaries: entity.anniversaries,
      dayOfTime: entity.dayOfTime,
      reminderEnabled: entity.reminderEnabled,
      reminderDaysBefore: entity.reminderDaysBefore,
      reminderTime: entity.reminderTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'newMemory': newMemory,
      'importantDates': importantDates,
      'anniversaries': anniversaries,
      'dayOfTime': formatTime(dayOfTime),
      'reminderEnabled': reminderEnabled,
      'reminderDaysBefore': reminderDaysBefore,
      'reminderTime': formatTime(reminderTime),
    };
  }

  // --- 540 -> "09:00" ---
  static String formatTime(int minutes) {
    final hours = (minutes ~/ 60).toString().padLeft(2, '0');
    final rest = (minutes % 60).toString().padLeft(2, '0');
    return '$hours:$rest';
  }

  // --- "09:00" -> 540. Null si le texte n'est pas une heure valable ---
  static int? parseTime(Object? value) {
    if (value is! String) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;
    return hours * 60 + minutes;
  }
}
