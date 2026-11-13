// ============================================================================
// TEST UNITAIRE : GetGifSearchTerm (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/settings/domain/entities/couple_settings_entity.dart';
import 'package:amor_app/features/settings/domain/repositories/couple_settings_repository.dart';
import 'package:amor_app/features/settings/domain/usecases/get_gif_search_term.dart';

class MockCoupleSettingsRepository extends Mock
    implements CoupleSettingsRepository {}

void main() {
  late MockCoupleSettingsRepository mockRepository;
  late GetGifSearchTerm useCase;

  setUp(() {
    mockRepository = MockCoupleSettingsRepository();
    useCase = GetGifSearchTerm(mockRepository);
  });

  void stubTerm(String term) {
    when(() => mockRepository.watchSettings()).thenAnswer(
      (_) => Stream.value(
        CoupleSettingsEntity.defaults().copyWith(gifSearchTerm: term),
      ),
    );
  }

  test('doit renvoyer le terme des paramètres, sans espaces autour', () async {
    stubTerm('  penguin hug ');

    expect(await useCase(), 'penguin hug');
  });

  test('doit reprendre le terme d\'origine pour un terme vide', () async {
    stubTerm('   ');

    expect(await useCase(), CoupleSettingsEntity.defaultGifSearchTerm);
  });

  test('doit reprendre le terme d\'origine si les paramètres échouent',
      () async {
    when(() => mockRepository.watchSettings())
        .thenAnswer((_) => Stream.error(Exception('Erreur réseau')));

    expect(await useCase(), CoupleSettingsEntity.defaultGifSearchTerm);
  });
}
