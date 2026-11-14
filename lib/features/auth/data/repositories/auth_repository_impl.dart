// ============================================================================
// AUTH REPOSITORY (IMPLEMENTATION)
// ============================================================================
// Délègue à la data source et convertit chaque AuthException en
// AuthFailure du domaine.

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_failure_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Stream<AppUser?> watchAuthState() => _remoteDataSource.watchAuthState();

  @override
  Future<AppUser?> signInWithGoogle() {
    return _guard(() => _remoteDataSource.signInWithGoogle());
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _remoteDataSource.signInWithEmail(email: email, password: password),
    );
  }

  @override
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _remoteDataSource.registerWithEmail(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _guard(() => _remoteDataSource.sendPasswordReset(email));
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  // --- Traduction des erreurs de la data source ---
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      throw AuthFailure(authFailureReasonFromCode(e.code));
    }
  }
}
