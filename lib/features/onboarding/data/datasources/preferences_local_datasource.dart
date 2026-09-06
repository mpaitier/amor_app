// ============================================================================
// PREFERENCES LOCAL DATA SOURCE
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesLocalDataSource {
  static const String _keyFirstRun = 'is_first_run';

  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstRun) ?? true;
  }

  Future<void> setFirstRunCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstRun, false);
  }
}