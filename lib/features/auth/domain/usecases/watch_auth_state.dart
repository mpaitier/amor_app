// ============================================================================
// USE CASE : WATCH AUTH STATE
// ============================================================================

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository _repository;

  const WatchAuthState(this._repository);

  Stream<AppUser?> call() => _repository.watchAuthState();
}
