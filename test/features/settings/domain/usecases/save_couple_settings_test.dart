// ============================================================================
// TEST UNITAIRE : SaveCoupleSettings (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';
import 'package:amor_app/features/settings/domain/repositories/couple_settings_repository.dart';
import 'package:amor_app/features/settings/domain/usecases/save_couple_settings.dart';

class MockCoupleSettingsRepository extends Mock
    implements CoupleSettingsRepository {}

void main() {
  late MockCoupleSettingsRepository mockRepository;
  late SaveCoupleSettings useCase;

  final tSettings = CoupleSettingsEntity.defaults().copyWith(
    showAnniversary: true,
  );

  setUp(() {
    mockRepository = MockCoupleSettingsRepository();
    useCase = SaveCoupleSettings(mockRepository);
  });

  test('doit appeler repository.saveSettings avec les réglages fournis',
      () async {
    when(() => mockRepository.saveSettings(tSettings)).thenAnswer((_) async {});

    await useCase(tSettings);

    verify(() => mockRepository.saveSettings(tSettings)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('doit laisser remonter l\'exception si le repository échoue',
      () async {
    when(() => mockRepository.saveSettings(tSettings))
        .thenThrow(Exception('Firestore indisponible'));

    expect(() => useCase(tSettings), throwsException);
  });
}
