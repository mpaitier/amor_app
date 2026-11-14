// ============================================================================
// TEST UNITAIRE : MemberProfileViewModel
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/couple/domain/entities/couple_failure.dart';
import 'package:amor_app/features/couple/domain/entities/couple_member.dart';
import 'package:amor_app/features/couple/domain/repositories/couple_repository.dart';
import 'package:amor_app/features/couple/domain/usecases/update_member_profile.dart';
import 'package:amor_app/features/couple/presentation/utils/couple_messages.dart';
import 'package:amor_app/features/couple/presentation/viewmodels/member_profile_viewmodel.dart';

class MockCoupleRepository extends Mock implements CoupleRepository {}

void main() {
  late MockCoupleRepository mockRepository;
  late MemberProfileViewModel viewModel;

  const tMember =
      CoupleMember(uid: 'uid-titi', nickname: 'Titi', color: 0xFF7B4FD6);

  void stubUpdate() {
    when(() => mockRepository.updateMemberProfile(
          coupleId: any(named: 'coupleId'),
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
        )).thenAnswer((_) async {});
  }

  setUp(() {
    mockRepository = MockCoupleRepository();
    viewModel = MemberProfileViewModel(
      updateMemberProfile: UpdateMemberProfile(mockRepository),
      coupleId: 'couple-1',
      member: tMember,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('démarre avec le profil enregistré', () {
    expect(viewModel.nicknameController.text, 'Titi');
    expect(viewModel.selectedColor, 0xFF7B4FD6);
  });

  test('selectColor enregistre aussitôt', () async {
    stubUpdate();

    await viewModel.selectColor(0xFFE0A800);

    verify(() => mockRepository.updateMemberProfile(
          coupleId: 'couple-1',
          uid: 'uid-titi',
          nickname: 'Titi',
          color: 0xFFE0A800,
        )).called(1);
    expect(viewModel.selectedColor, 0xFFE0A800);
  });

  test('selectColor ne fait rien pour la couleur déjà choisie', () async {
    await viewModel.selectColor(0xFF7B4FD6);

    verifyNever(() => mockRepository.updateMemberProfile(
          coupleId: any(named: 'coupleId'),
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
        ));
  });

  test('saveNickname enregistre un nouveau surnom', () async {
    stubUpdate();
    viewModel.nicknameController.text = ' Titou ';

    await viewModel.saveNickname();

    verify(() => mockRepository.updateMemberProfile(
          coupleId: 'couple-1',
          uid: 'uid-titi',
          nickname: 'Titou',
          color: 0xFF7B4FD6,
        )).called(1);
  });

  test('saveNickname ne fait rien si le surnom n\'a pas changé', () async {
    viewModel.nicknameController.text = 'Titi ';

    await viewModel.saveNickname();

    verifyNever(() => mockRepository.updateMemberProfile(
          coupleId: any(named: 'coupleId'),
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
        ));
  });

  test('un surnom vidé reprend l\'ancien', () async {
    viewModel.nicknameController.text = '   ';

    await viewModel.saveNickname();

    expect(viewModel.nicknameController.text, 'Titi');
    expect(viewModel.errorMessage, validateNickname(''));
  });

  test('un échec remet la couleur enregistrée', () async {
    when(() => mockRepository.updateMemberProfile(
          coupleId: any(named: 'coupleId'),
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
        )).thenThrow(const CoupleFailure(CoupleFailureReason.network));

    await viewModel.selectColor(0xFFE0A800);

    expect(viewModel.selectedColor, 0xFF7B4FD6);
    expect(
      viewModel.errorMessage,
      coupleFailureMessage(CoupleFailureReason.network),
    );
    expect(viewModel.isSaving, isFalse);
  });
}
