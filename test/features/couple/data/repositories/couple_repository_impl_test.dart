// ============================================================================
// TEST UNITAIRE : CoupleRepositoryImpl
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/core/error/exceptions.dart';
import 'package:amor_app/features/couple/data/datasources/couple_remote_datasource.dart';
import 'package:amor_app/features/couple/data/models/couple_model.dart';
import 'package:amor_app/features/couple/data/repositories/couple_repository_impl.dart';
import 'package:amor_app/features/couple/domain/entities/couple_failure.dart';

class MockCoupleRemoteDataSource extends Mock
    implements CoupleRemoteDataSource {}

void main() {
  late MockCoupleRemoteDataSource mockDataSource;
  late CoupleRepositoryImpl repository;

  Matcher failureWith(CoupleFailureReason reason) {
    return throwsA(
      isA<CoupleFailure>().having((f) => f.reason, 'reason', reason),
    );
  }

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    mockDataSource = MockCoupleRemoteDataSource();
    repository = CoupleRepositoryImpl(remoteDataSource: mockDataSource);
  });

  test('watchCurrentCouple relaie le flux de la data source', () async {
    const model = CoupleModel(id: 'c', members: [], inviteCode: 'K7PQ2A');
    when(() => mockDataSource.watchCurrentCouple('uid-1'))
        .thenAnswer((_) => Stream.value(model));

    expect(await repository.watchCurrentCouple('uid-1').first, model);
  });

  test('createCouple renvoie l\'id de la relation', () async {
    when(() => mockDataSource.createCouple(
          nickname: 'Titi',
          color: 1,
          relationshipStart: DateTime(2023, 12, 12),
        )).thenAnswer((_) async => 'couple-1');

    expect(
      await repository.createCouple(
        nickname: 'Titi',
        color: 1,
        relationshipStart: DateTime(2023, 12, 12),
      ),
      'couple-1',
    );
  });

  test('createCouple traduit un compte déjà en relation', () {
    when(() => mockDataSource.createCouple(
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
          relationshipStart: any(named: 'relationshipStart'),
        )).thenThrow(const CoupleException('already-exists'));

    expect(
      () => repository.createCouple(
        nickname: 'Titi',
        color: 1,
        relationshipStart: DateTime(2023, 12, 12),
      ),
      failureWith(CoupleFailureReason.alreadyInCouple),
    );
  });

  test('joinCouple traduit un code inconnu', () {
    when(() => mockDataSource.joinCouple(
          code: any(named: 'code'),
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
        )).thenThrow(const CoupleException('not-found'));

    expect(
      () => repository.joinCouple(code: 'K7PQ2A', nickname: 'Lulu', color: 2),
      failureWith(CoupleFailureReason.invalidCode),
    );
  });

  test('updateMemberProfile traduit un refus Firestore', () {
    when(() => mockDataSource.updateMemberProfile(
          coupleId: any(named: 'coupleId'),
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
          color: any(named: 'color'),
        )).thenThrow(const CoupleException('permission-denied'));

    expect(
      () => repository.updateMemberProfile(
        coupleId: 'c',
        uid: 'u',
        nickname: 'Titi',
        color: 1,
      ),
      failureWith(CoupleFailureReason.unknown),
    );
  });

  test('dayString formate la date en AAAA-MM-JJ', () {
    expect(CoupleRemoteDataSource.dayString(DateTime(2023, 2, 5)), '2023-02-05');
  });

  test('respondToEnd renvoie si la relation a été supprimée', () async {
    when(() => mockDataSource.respondToEnd(accept: true))
        .thenAnswer((_) async => true);

    expect(await repository.respondToEnd(accept: true), isTrue);
  });

  test('cancelEnd traduit un refus de la fonction', () {
    when(() => mockDataSource.cancelEnd())
        .thenThrow(const CoupleException('permission-denied'));

    expect(
      () => repository.cancelEnd(),
      failureWith(CoupleFailureReason.unknown),
    );
  });

  test('requestEnd traduit une coupure réseau', () {
    when(() => mockDataSource.requestEnd())
        .thenThrow(const CoupleException('unavailable'));

    expect(
      () => repository.requestEnd(),
      failureWith(CoupleFailureReason.network),
    );
  });
}
