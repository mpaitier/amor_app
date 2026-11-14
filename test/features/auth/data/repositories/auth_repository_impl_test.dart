// ============================================================================
// TEST UNITAIRE : AuthRepositoryImpl
// ============================================================================
// La data source est simulée : on vérifie la délégation et la traduction
// des AuthException en AuthFailure.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/core/error/exceptions.dart';
import 'package:amor_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:amor_app/features/auth/data/models/app_user_model.dart';
import 'package:amor_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:amor_app/features/auth/domain/entities/auth_failure.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  const tUser = AppUserModel(uid: 'uid-1', email: 'lulu@amor.fr');

  Matcher failureWith(AuthFailureReason reason) {
    return throwsA(
      isA<AuthFailure>().having((f) => f.reason, 'reason', reason),
    );
  }

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
  });

  test('watchAuthState doit relayer le flux de la data source', () async {
    when(() => mockDataSource.watchAuthState())
        .thenAnswer((_) => Stream.value(tUser));

    expect(await repository.watchAuthState().first, tUser);
  });

  test('signInWithEmail doit renvoyer la personne connectée', () async {
    when(() => mockDataSource.signInWithEmail(
          email: 'lulu@amor.fr',
          password: 'secret',
        )).thenAnswer((_) async => tUser);

    final result = await repository.signInWithEmail(
      email: 'lulu@amor.fr',
      password: 'secret',
    );

    expect(result, tUser);
  });

  test('signInWithEmail doit traduire un mauvais mot de passe', () {
    when(() => mockDataSource.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const AuthException('invalid-credential'));

    expect(
      () => repository.signInWithEmail(email: 'a@b.fr', password: 'x'),
      failureWith(AuthFailureReason.wrongCredentials),
    );
  });

  test('registerWithEmail doit traduire une adresse déjà prise', () {
    when(() => mockDataSource.registerWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const AuthException('email-already-in-use'));

    expect(
      () => repository.registerWithEmail(email: 'a@b.fr', password: 'secret'),
      failureWith(AuthFailureReason.emailAlreadyInUse),
    );
  });

  test('signInWithGoogle doit renvoyer null quand la personne annule',
      () async {
    when(() => mockDataSource.signInWithGoogle()).thenAnswer((_) async => null);

    expect(await repository.signInWithGoogle(), isNull);
  });

  test('signInWithGoogle doit traduire un échec Google', () {
    when(() => mockDataSource.signInWithGoogle())
        .thenThrow(const AuthException('google-sign-in-failed'));

    expect(
      () => repository.signInWithGoogle(),
      failureWith(AuthFailureReason.googleSignInFailed),
    );
  });

  test('sendPasswordReset doit traduire une adresse invalide', () {
    when(() => mockDataSource.sendPasswordReset(any()))
        .thenThrow(const AuthException('invalid-email'));

    expect(
      () => repository.sendPasswordReset('pas-une-adresse'),
      failureWith(AuthFailureReason.invalidEmail),
    );
  });

  test('signOut doit déléguer à la data source', () async {
    when(() => mockDataSource.signOut()).thenAnswer((_) async {});

    await repository.signOut();

    verify(() => mockDataSource.signOut()).called(1);
  });

  test('deleteAccount doit traduire une coupure réseau', () {
    when(() => mockDataSource.deleteAccount())
        .thenThrow(const AuthException('network-request-failed'));

    expect(
      () => repository.deleteAccount(),
      failureWith(AuthFailureReason.network),
    );
  });
}
