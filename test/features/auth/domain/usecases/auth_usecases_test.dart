// ============================================================================
// TEST UNITAIRE : use cases de la feature auth
// ============================================================================
// Chaque use case relaie au repository ; ceux qui reçoivent une adresse
// e-mail la nettoient des espaces.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/auth/domain/entities/app_user.dart';
import 'package:amor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:amor_app/features/auth/domain/usecases/register_with_email.dart';
import 'package:amor_app/features/auth/domain/usecases/send_password_reset.dart';
import 'package:amor_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:amor_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:amor_app/features/auth/domain/usecases/sign_out.dart';
import 'package:amor_app/features/auth/domain/usecases/watch_auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  const tUser = AppUser(uid: 'uid-1', email: 'lulu@amor.fr');

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('WatchAuthState', () {
    test('doit relayer le flux du repository', () async {
      when(() => mockRepository.watchAuthState())
          .thenAnswer((_) => Stream.value(tUser));

      final result = await WatchAuthState(mockRepository)().first;

      expect(result, tUser);
    });
  });

  group('SignInWithGoogle', () {
    test('doit renvoyer la personne connectée', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => tUser);

      final result = await SignInWithGoogle(mockRepository)();

      expect(result, tUser);
    });

    test('doit renvoyer null quand la personne annule', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => null);

      final result = await SignInWithGoogle(mockRepository)();

      expect(result, isNull);
    });
  });

  group('SignInWithEmail', () {
    test('doit retirer les espaces autour de l\'adresse', () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUser);

      await SignInWithEmail(mockRepository)(
        email: '  lulu@amor.fr ',
        password: ' secret ',
      );

      // --- Le mot de passe, lui, est transmis tel quel ---
      verify(() => mockRepository.signInWithEmail(
            email: 'lulu@amor.fr',
            password: ' secret ',
          )).called(1);
    });
  });

  group('RegisterWithEmail', () {
    test('doit retirer les espaces autour de l\'adresse', () async {
      when(() => mockRepository.registerWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUser);

      await RegisterWithEmail(mockRepository)(
        email: 'lulu@amor.fr  ',
        password: 'secret',
      );

      verify(() => mockRepository.registerWithEmail(
            email: 'lulu@amor.fr',
            password: 'secret',
          )).called(1);
    });
  });

  group('SendPasswordReset', () {
    test('doit retirer les espaces autour de l\'adresse', () async {
      when(() => mockRepository.sendPasswordReset(any()))
          .thenAnswer((_) async {});

      await SendPasswordReset(mockRepository)(' lulu@amor.fr ');

      verify(() => mockRepository.sendPasswordReset('lulu@amor.fr')).called(1);
    });
  });

  group('SignOut', () {
    test('doit déléguer au repository', () async {
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      await SignOut(mockRepository)();

      verify(() => mockRepository.signOut()).called(1);
    });
  });
}
