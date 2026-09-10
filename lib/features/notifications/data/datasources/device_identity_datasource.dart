import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentityDataSource {
  static const String _keyDeviceId = 'device_id';
  static const Uuid _uuid = Uuid();

  Future<String> getOrCreateDeviceId() async {
    // if we didn't already generate a device ID, 
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    // create one and store it in SharedPreferences
    final newId = _uuid.v4();
    await prefs.setString(_keyDeviceId, newId);
    return newId;
  }
}