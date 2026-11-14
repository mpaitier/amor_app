// ============================================================================
// USE CASE : UNREGISTER DEVICE TOKEN
// ============================================================================
// Détache le téléphone du compte avant la déconnexion. Sans cela, il
// continuerait de recevoir les notifications de la relation.

import '../repositories/notification_repository.dart';

class UnregisterDeviceToken {
  final NotificationRepository _repository;

  const UnregisterDeviceToken(this._repository);

  Future<void> call() => _repository.unregisterDeviceToken();
}
