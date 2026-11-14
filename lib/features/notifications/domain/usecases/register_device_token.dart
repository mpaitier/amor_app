// ============================================================================
// USE CASE : REGISTER DEVICE TOKEN
// ============================================================================
// Enregistre le jeton FCM du téléphone, rattaché au compte connecté. Appelé
// au lancement, puis dès qu'une relation devient active.

import '../repositories/notification_repository.dart';

class RegisterDeviceToken {
  final NotificationRepository _repository;

  const RegisterDeviceToken(this._repository);

  Future<void> call() => _repository.registerDeviceToken();
}
