// ============================================================================
// TEST UNITAIRE : CoupleSettingsRepositoryImpl
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/settings/data/datasources/couple_settings_remote_datasource.dart';
import 'package:amor_app/features/settings/data/models/couple_settings_model.dart';
import 'package:amor_app/features/settings/data/repositories/couple_settings_repository_impl.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';

class MockCoupleSettingsRemoteDataSource extends Mock
    implements CoupleSettingsRemoteDataSource {}

// --- Fake utilisé uniquement pour enregistrer une valeur de repli auprès
// --- de mocktail (nécessaire pour matcher any() sur un type non natif) ---
class _FakeCoupleSettingsModel extends Fake implements CoupleSettingsModel {}

void main() {
  late MockCoupleSettingsRemoteDataSource mockDataSource;
  late CoupleSettingsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeCoupleSettingsModel());
  });

  setUp(() {
    mockDataSource = MockCoupleSettingsRemoteDataSource();
    repository = CoupleSettingsRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final tEntity = CoupleSettingsEntity.defaults().copyWith(
    showMonthAnniversaries: true,
  );

  test('watchSettings doit relayer le flux de la source distante', () async {
    when(() => mockDataSource.watchSettings()).thenAnswer(
      (_) => Stream.value(CoupleSettingsModel.fromEntity(tEntity)),
    );

    final result = await repository.watchSettings().first;

    expect(result.showMonthAnniversaries, isTrue);
  });

  test('saveSettings doit convertir l\'entité en modèle avant l\'envoi',
      () async {
    when(() => mockDataSource.saveSettings(any())).thenAnswer((_) async {});

    await repository.saveSettings(tEntity);

    final captured =
        verify(() => mockDataSource.saveSettings(captureAny())).captured.single
            as CoupleSettingsModel;
    expect(captured.relationshipStart, tEntity.relationshipStart);
    expect(captured.showMonthAnniversaries, isTrue);
  });
}
