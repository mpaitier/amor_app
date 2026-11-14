// ============================================================================
// TEST UNITAIRE : use cases de la feature couple
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/couple/domain/entities/couple_entity.dart';
import 'package:amor_app/features/couple/domain/entities/couple_failure.dart';
import 'package:amor_app/features/couple/domain/repositories/couple_repository.dart';
import 'package:amor_app/features/couple/domain/usecases/create_couple.dart';
import 'package:amor_app/features/couple/domain/usecases/join_couple.dart';
import 'package:amor_app/features/couple/domain/usecases/update_member_profile.dart';
import 'package:amor_app/features/couple/domain/usecases/watch_current_couple.dart';

class MockCoupleRepository extends Mock implements CoupleRepository {}

void main() {
  late MockCoupleRepository mockRepository;

  Matcher failureWith(CoupleFailureReason reason) {
    return throwsA(
      isA<CoupleFailure>().having((f) => f.reason, 'reason', reason),
    );
  }

  setUp(() {
    mockRepository = MockCoupleRepository();
  });

  test('WatchCurrentCouple relaie le flux du repository', () async {
    const couple = CoupleEntity(id: 'c', members: [], inviteCode: 'K7PQ2A');
    when(() => mockRepository.watchCurrentCouple('uid-1'))
        .thenAnswer((_) => Stream.value(couple));

    expect(await WatchCurrentCouple(mockRepository)('uid-1').first, couple);
  });

  group('CreateCouple', () {
    test('nettoie le surnom avant l\'envoi', () async {
      when(() => mockRepository.createCouple(
            nickname: any(named: 'nickname'),
            color: any(named: 'color'),
          )).thenAnswer((_) async => 'couple-1');

      final id = await CreateCouple(mockRepository)(
        nickname: '  Titi ',
        color: 0xFF7B4FD6,
      );

      expect(id, 'couple-1');
      verify(() => mockRepository.createCouple(
            nickname: 'Titi',
            color: 0xFF7B4FD6,
          )).called(1);
    });

    test('refuse un surnom vide sans appel réseau', () {
      expect(
        () => CreateCouple(mockRepository)(nickname: '  ', color: 1),
        failureWith(CoupleFailureReason.invalidProfile),
      );
      verifyNever(() => mockRepository.createCouple(
            nickname: any(named: 'nickname'),
            color: any(named: 'color'),
          ));
    });
  });

  group('JoinCouple', () {
    test('normalise le code avant l\'envoi', () async {
      when(() => mockRepository.joinCouple(
            code: any(named: 'code'),
            nickname: any(named: 'nickname'),
            color: any(named: 'color'),
          )).thenAnswer((_) async => 'couple-1');

      await JoinCouple(mockRepository)(
        code: ' k7p-q2a ',
        nickname: 'Lulu ',
        color: 0xFFE0A800,
      );

      verify(() => mockRepository.joinCouple(
            code: 'K7PQ2A',
            nickname: 'Lulu',
            color: 0xFFE0A800,
          )).called(1);
    });

    test('refuse un code mal formé sans appel réseau', () {
      expect(
        () => JoinCouple(mockRepository)(
          code: 'ABC',
          nickname: 'Lulu',
          color: 1,
        ),
        failureWith(CoupleFailureReason.invalidCode),
      );
    });

    test('refuse un surnom vide', () {
      expect(
        () => JoinCouple(mockRepository)(
          code: 'K7PQ2A',
          nickname: '',
          color: 1,
        ),
        failureWith(CoupleFailureReason.invalidProfile),
      );
    });
  });

  group('UpdateMemberProfile', () {
    test('nettoie le surnom avant l\'envoi', () async {
      when(() => mockRepository.updateMemberProfile(
            coupleId: any(named: 'coupleId'),
            uid: any(named: 'uid'),
            nickname: any(named: 'nickname'),
            color: any(named: 'color'),
          )).thenAnswer((_) async {});

      await UpdateMemberProfile(mockRepository)(
        coupleId: 'couple-1',
        uid: 'uid-1',
        nickname: ' Titou ',
        color: 3,
      );

      verify(() => mockRepository.updateMemberProfile(
            coupleId: 'couple-1',
            uid: 'uid-1',
            nickname: 'Titou',
            color: 3,
          )).called(1);
    });

    test('refuse un surnom vide', () {
      expect(
        () => UpdateMemberProfile(mockRepository)(
          coupleId: 'couple-1',
          uid: 'uid-1',
          nickname: ' ',
          color: 3,
        ),
        failureWith(CoupleFailureReason.invalidProfile),
      );
    });
  });
}
