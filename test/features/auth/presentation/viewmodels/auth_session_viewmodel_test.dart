// ============================================================================
// TEST UNITAIRE : AuthSessionViewModel
// ============================================================================
// Le flux de connexion est piloté par un StreamController.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/auth/domain/entities/app_user.dart';
import 'package:amor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:amor_app/features/auth/domain/usecases/sign_out.dart';
import 'package:amor_app/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:amor_app/features/auth/presentation/viewmodels/auth_session_viewmodel.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late StreamController<AppUser?> authController;
  late AuthSessionViewModel viewModel;

  Future<void> flushStream() => Future<void>.delayed(Duration.zero);

  const tUser = AppUser(uid: 'uid-1', email: 'lulu@amor.fr');

  setUp(() {
    mockRepository = MockAuthRepository();
    authController = StreamController<AppUser?>();
    when(() => mockRepository.watchAuthState())
        .thenAnswer((_) => authController.stream);
    when(() => mockRepository.signOut()).thenAnswer((_) async {});

    viewModel = AuthSessionViewModel(
      watchAuthState: WatchAuthState(mockRepository),
      signOut: SignOut(mockRepository),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await authController.close();
  });

  test('l\'état est inconnu tant que Firebase n\'a pas répondu', () {
    expect(viewModel.status, AuthStatus.unknown);
    expect(viewModel.user, isNull);
  });

  test('passe à signedIn quand une personne est connectée', () async {
    authController.add(tUser);
    await flushStream();

    expect(viewModel.status, AuthStatus.signedIn);
    expect(viewModel.isSignedIn, isTrue);
    expect(viewModel.user, tUser);
  });

  test('passe à signedOut quand personne n\'est connecté', () async {
    authController.add(tUser);
    await flushStream();
    authController.add(null);
    await flushStream();

    expect(viewModel.status, AuthStatus.signedOut);
    expect(viewModel.user, isNull);
  });

  test('un flux en erreur renvoie vers la connexion', () async {
    authController.addError(Exception('Erreur réseau'));
    await flushStream();

    expect(viewModel.status, AuthStatus.signedOut);
  });

  test('prévient ses auditeurs à chaque changement', () async {
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    authController.add(tUser);
    await flushStream();
    authController.add(null);
    await flushStream();

    expect(notifications, 2);
  });

  test('signOut doit passer par le use case', () async {
    await viewModel.signOut();

    verify(() => mockRepository.signOut()).called(1);
  });
}
