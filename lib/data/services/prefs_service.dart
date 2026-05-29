// <<===========================================================================>>
// <<========================== SERVICE PRÉFÉRENCES ============================>>
// <<===========================================================================>>

import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  // <<--- Clés --->
  static const String _keyFirstRun = 'is_first_run';

  // <<--- Vérifie si c'est le premier lancement --->
  static Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstRun) ?? true;
  }

  // <<--- Marque le premier lancement comme terminé --->
  static Future<void> setFirstRunCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstRun, false);
  }
}