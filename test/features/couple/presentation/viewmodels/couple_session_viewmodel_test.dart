// ============================================================================
// TEST UNITAIRE : CoupleSessionViewModel
// ============================================================================
// La session de connexion est réelle, branchée sur un AuthRepository
// simulé. Les flux de connexion et de relation sont pilotés par des
// StreamController.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/auth/domain/entities/app_user.dart';
import 'package:amor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:amor_app/features/auth/domain/usecases/sign_out.dart';
import 'package:amor_app/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:amor_app/features/auth/presentation/viewmodels/auth_session_viewmodel.dart';
import 'package:amor_app/features/couple/domain/entities/couple_entity.dart';
import 'package:amor_app/features/couple/domain/entities/couple_member.dart';
import 'package:amor_app/features/couple/domain/repositories/couple_repository.dart';
import 'package:amor_app/features/couple/domain/usecases/watch_current_couple.dart';
import 'package:amor_app/features/couple/presentation/viewmodels/couple_session_viewmodel.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockCoupleRepository extends Mock implements CoupleRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockCoupleRepository mockCoupleRepository;
  late StreamController<AppUser?> authController;
  late Map<String, StreamController<CoupleEntity?>> coupleControllers;
  late AuthSessionViewModel authSession;
  late CoupleSessionViewModel viewModel;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  const titi = AppUser(uid: 'uid-titi', email: 'titi@amor.fr');
  const lulu = AppUser(uid: 'uid-lulu', email: 'lulu@amor.fr');

  const titiMember =
      CoupleMember(uid: 'uid-titi', nickname: 'Titi', color: 0xFF7B4FD6);
  const couple = CoupleEntity(
    id: 'couple-1',
    members: [titiMember],
    inviteCode: 'K7PQ2A',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockCoupleRepository = MockCoupleRepository();
    authController = StreamController<AppUser?>();
    coupleControllers = {
      'uid-titi': StreamController<CoupleEntity?>(),
      'uid-lulu': StreamController<CoupleEntity?>(),
    };

    when(() => mockAuthRepository.watchAuthState())
        .thenAnswer((_) => authController.stream);
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
    when(() => mockCoupleRepository.watchCurrentCouple(any())).thenAnswer(
      (invocation) =>
          coupleControllers[invocation.positionalArguments.first]!.stream,
    );

    authSession = AuthSessionViewModel(
      watchAuthState: WatchAuthState(mockAuthRepository),
      signOut: SignOut(mockAuthRepository),
    );
    viewModel = CoupleSessionViewModel(
      authSession: authSession,
      watchCurrentCouple: WatchCurrentCouple(mockCoupleRepository),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    authSession.dispose();
    await authController.close();
    for (final controller in coupleControllers.values) {
      await controller.close();
    }
  });

  test('en chargement tant que la connexion est inconnue', () {
    expect(viewModel.status, SessionStatus.loading);
  });

  test('déconnecté quand personne n\'est connecté', () async {
    authController.add(null);
    await flush();

    expect(viewModel.status, SessionStatus.signedOut);
    verifyNever(() => mockCoupleRepository.watchCurrentCouple(any()));
  });

  test('en chargement tant que la relation n\'est pas connue', () async {
    authController.add(titi);
    await flush();

    expect(viewModel.status, SessionStatus.loading);
    verify(() => mockCoupleRepository.watchCurrentCouple('uid-titi'))
        .called(1);
  });

  test('needsCouple quand la personne n\'a pas de relation', () async {
    authController.add(titi);
    await flush();
    coupleControllers['uid-titi']!.add(null);
    await flush();

    expect(viewModel.status, SessionStatus.needsCouple);
    expect(viewModel.couple, isNull);
  });

  test('ready avec la relation et le profil de la personne', () async {
    authController.add(titi);
    await flush();
    coupleControllers['uid-titi']!.add(couple);
    await flush();

    expect(viewModel.status, SessionStatus.ready);
    expect(viewModel.coupleId, 'couple-1');
    expect(viewModel.me, titiMember);
  });

  test('une relation dont la personne ne fait pas partie ne compte pas',
      () async {
    authController.add(lulu);
    await flush();
    coupleControllers['uid-lulu']!.add(couple);
    await flush();

    expect(viewModel.status, SessionStatus.needsCouple);
    expect(viewModel.me, isNull);
  });

  test('un refus de lecture renvoie vers la création de relation', () async {
    authController.add(titi);
    await flush();
    coupleControllers['uid-titi']!.addError(Exception('permission-denied'));
    await flush();

    expect(viewModel.status, SessionStatus.needsCouple);
  });

  test('un changement de compte suit la relation du nouveau', () async {
    authController.add(titi);
    await flush();
    coupleControllers['uid-titi']!.add(couple);
    await flush();

    authController.add(lulu);
    await flush();

    expect(viewModel.status, SessionStatus.loading);
    expect(coupleControllers['uid-titi']!.hasListener, isFalse);
    verify(() => mockCoupleRepository.watchCurrentCouple('uid-lulu'))
        .called(1);
  });

  test('la déconnexion arrête de suivre la relation', () async {
    authController.add(titi);
    await flush();
    coupleControllers['uid-titi']!.add(couple);
    await flush();

    authController.add(null);
    await flush();

    expect(viewModel.status, SessionStatus.signedOut);
    expect(viewModel.couple, isNull);
    expect(coupleControllers['uid-titi']!.hasListener, isFalse);
  });

  test('signOut passe par la session de connexion', () async {
    await viewModel.signOut();

    verify(() => mockAuthRepository.signOut()).called(1);
  });
}
