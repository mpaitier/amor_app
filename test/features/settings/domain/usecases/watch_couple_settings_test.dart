// ============================================================================
// TEST UNITAIRE : WatchCoupleSettings (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';
import 'package:amor_app/features/settings/domain/repositories/couple_settings_repository.dart';
import 'package:amor_app/features/settings/domain/usecases/watch_couple_settings.dart';

class MockCoupleSettingsRepository extends Mock
    implements CoupleSettingsRepository {}

void main() {
  late MockCoupleSettingsRepository mockRepository;
  late WatchCoupleSettings useCase;

  setUp(() {
    mockRepository = MockCoupleSettingsRepository();
    useCase = WatchCoupleSettings(mockRepository);
  });

  test('doit relayer le flux de réglages exposé par le repository', () async {
    final settings = CoupleSettingsEntity.defaults();
    when(() => mockRepository.watchSettings())
        .thenAnswer((_) => Stream.value(settings));

    final result = await useCase().first;

    expect(result, settings);
    verify(() => mockRepository.watchSettings()).called(1);
  });

  test('doit relayer les erreurs émises par le flux du repository', () async {
    when(() => mockRepository.watchSettings())
        .thenAnswer((_) => Stream.error(Exception('Erreur réseau')));

    expect(useCase(), emitsError(isA<Exception>()));
  });
}
