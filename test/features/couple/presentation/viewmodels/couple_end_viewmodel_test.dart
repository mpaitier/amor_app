// ============================================================================
// TEST UNITAIRE : CoupleEndViewModel
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/couple/domain/entities/couple_failure.dart';
import 'package:amor_app/features/couple/domain/repositories/couple_repository.dart';
import 'package:amor_app/features/couple/domain/usecases/cancel_couple_end.dart';
import 'package:amor_app/features/couple/domain/usecases/request_couple_end.dart';
import 'package:amor_app/features/couple/domain/usecases/respond_to_couple_end.dart';
import 'package:amor_app/features/couple/presentation/utils/couple_messages.dart';
import 'package:amor_app/features/couple/presentation/viewmodels/couple_end_viewmodel.dart';

class MockCoupleRepository extends Mock implements CoupleRepository {}

void main() {
  late MockCoupleRepository mockRepository;
  late CoupleEndViewModel viewModel;

  setUp(() {
    mockRepository = MockCoupleRepository();
    viewModel = CoupleEndViewModel(
      requestCoupleEnd: RequestCoupleEnd(mockRepository),
      respondToCoupleEnd: RespondToCoupleEnd(mockRepository),
      cancelCoupleEnd: CancelCoupleEnd(mockRepository),
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('requestEnd envoie la demande', () async {
    when(() => mockRepository.requestEnd()).thenAnswer((_) async => false);

    expect(await viewModel.requestEnd(), isTrue);
    expect(viewModel.isBusy, isFalse);
    expect(viewModel.errorMessage, isNull);
  });

  test('accept et decline transmettent la réponse', () async {
    when(() => mockRepository.respondToEnd(accept: any(named: 'accept')))
        .thenAnswer((_) async => false);

    await viewModel.accept();
    await viewModel.decline();

    verify(() => mockRepository.respondToEnd(accept: true)).called(1);
    verify(() => mockRepository.respondToEnd(accept: false)).called(1);
  });

  test('cancel retire la demande', () async {
    when(() => mockRepository.cancelEnd()).thenAnswer((_) async {});

    expect(await viewModel.cancel(), isTrue);
    verify(() => mockRepository.cancelEnd()).called(1);
  });

  test('un échec affiche un message et renvoie false', () async {
    when(() => mockRepository.requestEnd())
        .thenThrow(const CoupleFailure(CoupleFailureReason.network));

    expect(await viewModel.requestEnd(), isFalse);
    expect(
      viewModel.errorMessage,
      coupleFailureMessage(CoupleFailureReason.network),
    );
    expect(viewModel.isBusy, isFalse);
  });

  test('une erreur inattendue donne le message générique', () async {
    when(() => mockRepository.cancelEnd()).thenThrow(Exception('boom'));

    await viewModel.cancel();

    expect(
      viewModel.errorMessage,
      coupleFailureMessage(CoupleFailureReason.unknown),
    );
  });
}
