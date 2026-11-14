// ============================================================================
// TEST UNITAIRE : SignInViewModel
// ============================================================================
// Les use cases sont réels, branchés sur un repository simulé.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/auth/domain/entities/app_user.dart';
import 'package:amor_app/features/auth/domain/entities/auth_failure.dart';
import 'package:amor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:amor_app/features/auth/domain/usecases/register_with_email.dart';
import 'package:amor_app/features/auth/domain/usecases/send_password_reset.dart';
import 'package:amor_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:amor_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:amor_app/features/auth/presentation/utils/auth_messages.dart';
import 'package:amor_app/features/auth/presentation/viewmodels/sign_in_viewmodel.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SignInViewModel viewModel;

  const tUser = AppUser(uid: 'uid-1', email: 'lulu@amor.fr');

  void stubSignInWithEmail() {
    when(() => mockRepository.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => tUser);
  }

  void stubRegisterWithEmail() {
    when(() => mockRepository.registerWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => tUser);
  }

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = SignInViewModel(
      signInWithGoogle: SignInWithGoogle(mockRepository),
      signInWithEmail: SignInWithEmail(mockRepository),
      registerWithEmail: RegisterWithEmail(mockRepository),
      sendPasswordReset: SendPasswordReset(mockRepository),
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('mode', () {
    test('démarre en mode connexion', () {
      expect(viewModel.mode, SignInMode.signIn);
      expect(viewModel.isRegistering, isFalse);
    });

    test('toggleMode bascule et efface les messages et la confirmation',
        () async {
      viewModel.confirmationController.text = 'secret';
      await viewModel.submitEmail(); // --- champs vides : erreur ---
      expect(viewModel.errorMessage, isNotNull);

      viewModel.toggleMode();

      expect(viewModel.mode, SignInMode.register);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.confirmationController.text, isEmpty);
    });
  });

  group('submitEmail en mode connexion', () {
    test('n\'appelle pas Firebase si l\'adresse est invalide', () async {
      viewModel.emailController.text = 'lulu';
      viewModel.passwordController.text = 'secret';

      await viewModel.submitEmail();

      expect(viewModel.errorMessage, validateEmail('lulu'));
      verifyNever(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('se connecte avec les valeurs saisies', () async {
      stubSignInWithEmail();
      viewModel.emailController.text = ' lulu@amor.fr ';
      viewModel.passwordController.text = 'abc';

      await viewModel.submitEmail();

      verify(() => mockRepository.signInWithEmail(
            email: 'lulu@amor.fr',
            password: 'abc',
          )).called(1);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isBusy, isFalse);
    });

    test('traduit un échec Firebase en message', () async {
      when(() => mockRepository.signInWithEmail(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenThrow(const AuthFailure(AuthFailureReason.wrongCredentials));
      viewModel.emailController.text = 'lulu@amor.fr';
      viewModel.passwordController.text = 'faux';

      await viewModel.submitEmail();

      expect(
        viewModel.errorMessage,
        authFailureMessage(AuthFailureReason.wrongCredentials),
      );
      expect(viewModel.isBusy, isFalse);
    });

    test('une erreur inattendue donne le message générique', () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('boom'));
      viewModel.emailController.text = 'lulu@amor.fr';
      viewModel.passwordController.text = 'secret';

      await viewModel.submitEmail();

      expect(
        viewModel.errorMessage,
        authFailureMessage(AuthFailureReason.unknown),
      );
    });
  });

  group('submitEmail en mode création de compte', () {
    setUp(() {
      viewModel.toggleMode();
      viewModel.emailController.text = 'lulu@amor.fr';
    });

    test('refuse un mot de passe trop court', () async {
      viewModel.passwordController.text = 'abc';
      viewModel.confirmationController.text = 'abc';

      await viewModel.submitEmail();

      expect(viewModel.errorMessage, isNotNull);
      verifyNever(() => mockRepository.registerWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('refuse une confirmation différente', () async {
      viewModel.passwordController.text = 'secret';
      viewModel.confirmationController.text = 'secrète';

      await viewModel.submitEmail();

      expect(
        viewModel.errorMessage,
        validateConfirmation('secret', 'secrète'),
      );
    });

    test('crée le compte quand tout est bon', () async {
      stubRegisterWithEmail();
      viewModel.passwordController.text = 'secret';
      viewModel.confirmationController.text = 'secret';

      await viewModel.submitEmail();

      verify(() => mockRepository.registerWithEmail(
            email: 'lulu@amor.fr',
            password: 'secret',
          )).called(1);
      expect(viewModel.errorMessage, isNull);
    });
  });

  group('continueWithGoogle', () {
    test('aucun message quand la personne annule', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => null);

      await viewModel.continueWithGoogle();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isBusy, isFalse);
    });

    test('affiche un message quand Google échoue', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenThrow(const AuthFailure(AuthFailureReason.googleSignInFailed));

      await viewModel.continueWithGoogle();

      expect(
        viewModel.errorMessage,
        authFailureMessage(AuthFailureReason.googleSignInFailed),
      );
    });
  });

  group('resetPassword', () {
    test('demande une adresse avant d\'envoyer', () async {
      await viewModel.resetPassword();

      expect(viewModel.errorMessage, validateEmail(''));
      verifyNever(() => mockRepository.sendPasswordReset(any()));
    });

    test('affiche une confirmation après l\'envoi', () async {
      when(() => mockRepository.sendPasswordReset(any()))
          .thenAnswer((_) async {});
      viewModel.emailController.text = 'lulu@amor.fr';

      await viewModel.resetPassword();

      verify(() => mockRepository.sendPasswordReset('lulu@amor.fr')).called(1);
      expect(viewModel.infoMessage, contains('lulu@amor.fr'));
      expect(viewModel.errorMessage, isNull);
    });
  });
}
