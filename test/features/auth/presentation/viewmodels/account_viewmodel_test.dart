// ============================================================================
// TEST UNITAIRE : AccountViewModel
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/auth/domain/entities/auth_failure.dart';
import 'package:amor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:amor_app/features/auth/domain/usecases/delete_account.dart';
import 'package:amor_app/features/auth/presentation/utils/auth_messages.dart';
import 'package:amor_app/features/auth/presentation/viewmodels/account_viewmodel.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AccountViewModel viewModel;

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = AccountViewModel(deleteAccount: DeleteAccount(mockRepository));
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('supprime le compte', () async {
    when(() => mockRepository.deleteAccount()).thenAnswer((_) async {});

    expect(await viewModel.deleteAccount(), isTrue);
    expect(viewModel.isDeleting, isFalse);
    expect(viewModel.errorMessage, isNull);
  });

  test('un échec affiche un message', () async {
    when(() => mockRepository.deleteAccount())
        .thenThrow(const AuthFailure(AuthFailureReason.network));

    expect(await viewModel.deleteAccount(), isFalse);
    expect(
      viewModel.errorMessage,
      authFailureMessage(AuthFailureReason.network),
    );
    expect(viewModel.isDeleting, isFalse);
  });

  test('une erreur inattendue donne le message générique', () async {
    when(() => mockRepository.deleteAccount()).thenThrow(Exception('boom'));

    await viewModel.deleteAccount();

    expect(
      viewModel.errorMessage,
      authFailureMessage(AuthFailureReason.unknown),
    );
  });
}
