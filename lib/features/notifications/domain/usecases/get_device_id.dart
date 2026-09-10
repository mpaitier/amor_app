import '../repositories/notification_repository.dart';

class GetDeviceId {
  final NotificationRepository _repository;
  const GetDeviceId(this._repository);

  Future<String> call() => _repository.getDeviceId();
}