// ============================================================================
// TEST UNITAIRE : CoupleSetupViewModel
// ============================================================================
// Les use cases sont réels, branchés sur un repository simulé.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/couple/domain/entities/couple_failure.dart';
import 'package:amor_app/features/couple/domain/repositories/couple_repository.dart';
import 'package:amor_app/features/couple/domain/usecases/create_couple.dart';
import 'package:amor_app/features/couple/domain/usecases/join_couple.dart';
import 'package:amor_app/features/couple/presentation/models/member_color_palette.dart';
import 'package:amor_app/features/couple/presentation/models/pending_invite.dart';
import 'package:amor_app/features/couple/presentation/utils/couple_messages.dart';
import 'package:amor_app/features/couple/presentation/viewmodels/couple_setup_viewmodel.dart';

class MockCoupleRepository extends Mock implements CoupleRepository {}

void main() {
  late MockCoupleRepository mockRepository;
  late PendingInvite pendingInvite;

  CoupleSetupViewModel buildViewModel() {
    return CoupleSetupViewModel(
      createCouple: CreateCouple(mockRepository),
      joinCouple: JoinCouple(mockRepository),
      pendingInvite: pendingInvite,
    );
  }

  void stubCreate() {
    when(() => mockRepository.createCouple(
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
        )).thenAnswer((_) async => 'couple-1');
  }

  void stubJoin() {
    when(() => mockRepository.joinCouple(
          code: any(named: 'code'),
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
        )).thenAnswer((_) async => 'couple-1');
  }

  setUp(() {
    mockRepository = MockCoupleRepository();
    pendingInvite = PendingInvite();
  });

  group('état initial', () {
    test('mode création et couleur par défaut sans lien', () {
      final viewModel = buildViewModel();

      expect(viewModel.mode, CoupleSetupMode.create);
      expect(viewModel.selectedColor, MemberColorPalette.defaultColor);
      viewModel.dispose();
    });

    test('mode adhésion avec le code pré-rempli après un lien', () {
      pendingInvite.remember('K7PQ2A');
      final viewModel = buildViewModel();

      expect(viewModel.mode, CoupleSetupMode.join);
      expect(viewModel.codeController.text, 'K7PQ2A');
      viewModel.dispose();
    });

    test('un lien reçu pendant l\'affichage remplit le code', () {
      final viewModel = buildViewModel();

      pendingInvite.remember('K7PQ2A');

      expect(viewModel.isJoining, isTrue);
      expect(viewModel.codeController.text, 'K7PQ2A');
      viewModel.dispose();
    });
  });

  group('submit en création', () {
    test('demande un surnom avant tout appel', () async {
      final viewModel = buildViewModel();

      await viewModel.submit();

      expect(viewModel.errorMessage, validateNickname(''));
      verifyNever(() => mockRepository.createCouple(
            nickname: any(named: 'nickname'),
            color: any(named: 'color'),
          ));
      viewModel.dispose();
    });

    test('crée la relation avec le surnom et la couleur choisis', () async {
      stubCreate();
      final viewModel = buildViewModel();
      viewModel.nicknameController.text = 'Titi';
      viewModel.selectColor(0xFFE0A800);

      await viewModel.submit();

      verify(() => mockRepository.createCouple(
            nickname: 'Titi',
            color: 0xFFE0A800,
          )).called(1);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isBusy, isFalse);
      viewModel.dispose();
    });

    test('affiche un message quand le compte a déjà une relation', () async {
      when(() => mockRepository.createCouple(
                nickname: any(named: 'nickname'),
                color: any(named: 'color'),
              ))
          .thenThrow(const CoupleFailure(CoupleFailureReason.alreadyInCouple));
      final viewModel = buildViewModel();
      viewModel.nicknameController.text = 'Titi';

      await viewModel.submit();

      expect(
        viewModel.errorMessage,
        coupleFailureMessage(CoupleFailureReason.alreadyInCouple),
      );
      viewModel.dispose();
    });
  });

  group('submit en adhésion', () {
    test('demande un code valable avant tout appel', () async {
      final viewModel = buildViewModel();
      viewModel.selectMode(CoupleSetupMode.join);
      viewModel.nicknameController.text = 'Lulu';
      viewModel.codeController.text = 'ABC';

      await viewModel.submit();

      expect(viewModel.errorMessage, validateInviteCode('ABC'));
      verifyNever(() => mockRepository.joinCouple(
            code: any(named: 'code'),
            nickname: any(named: 'nickname'),
            color: any(named: 'color'),
          ));
      viewModel.dispose();
    });

    test('rejoint la relation et oublie le lien reçu', () async {
      stubJoin();
      pendingInvite.remember('K7PQ2A');
      final viewModel = buildViewModel();
      viewModel.nicknameController.text = 'Lulu';

      await viewModel.submit();

      verify(() => mockRepository.joinCouple(
            code: 'K7PQ2A',
            nickname: 'Lulu',
            color: MemberColorPalette.defaultColor,
          )).called(1);
      expect(pendingInvite.code, isNull);
      viewModel.dispose();
    });

    test('affiche un message pour un code inconnu', () async {
      when(() => mockRepository.joinCouple(
            code: any(named: 'code'),
            nickname: any(named: 'nickname'),
            color: any(named: 'color'),
          )).thenThrow(const CoupleFailure(CoupleFailureReason.invalidCode));
      final viewModel = buildViewModel();
      viewModel.selectMode(CoupleSetupMode.join);
      viewModel.nicknameController.text = 'Lulu';
      viewModel.codeController.text = 'K7PQ2A';

      await viewModel.submit();

      expect(
        viewModel.errorMessage,
        coupleFailureMessage(CoupleFailureReason.invalidCode),
      );
      viewModel.dispose();
    });
  });

  test('changer de mode efface le message d\'erreur', () async {
    final viewModel = buildViewModel();
    await viewModel.submit();
    expect(viewModel.errorMessage, isNotNull);

    viewModel.selectMode(CoupleSetupMode.join);

    expect(viewModel.errorMessage, isNull);
    viewModel.dispose();
  });
}
