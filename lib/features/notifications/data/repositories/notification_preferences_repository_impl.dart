// ============================================================================
// NOTIFICATION PREFERENCES REPOSITORY (IMPLEMENTATION)
// ============================================================================
// Retrouve l'identifiant de ce téléphone, puis lit ou écrit ses préférences.

import 'dart:async';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../datasources/device_identity_datasource.dart';
import '../datasources/notification_preferences_remote_datasource.dart';
import '../models/notification_preferences_model.dart';

class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  final NotificationPreferencesRemoteDataSource _remoteDataSource;
  final DeviceIdentityDataSource _deviceIdentityDataSource;

  const NotificationPreferencesRepositoryImpl({
    required NotificationPreferencesRemoteDataSource remoteDataSource,
    required DeviceIdentityDataSource deviceIdentityDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _deviceIdentityDataSource = deviceIdentityDataSource;

  @override
  Stream<NotificationPreferences> watchPreferences() async* {
    final deviceId = await _deviceIdentityDataSource.getOrCreateDeviceId();
    yield* _remoteDataSource.watchPreferences(deviceId);
  }

  @override
  Future<void> savePreferences(NotificationPreferences preferences) async {
    final deviceId = await _deviceIdentityDataSource.getOrCreateDeviceId();
    await _remoteDataSource.savePreferences(
      deviceId,
      NotificationPreferencesModel.fromEntity(preferences),
    );
  }
}
