import '../repositories/notification_repository.dart';

class InitializeNotifications {
  final NotificationRepository _repository;
  const InitializeNotifications(this._repository);

  Future<void> call() => _repository.initialize();
}