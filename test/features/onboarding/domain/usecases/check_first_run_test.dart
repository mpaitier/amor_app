// ============================================================================
// TEST UNITAIRE : CheckFirstRun (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/onboarding/domain/repositories/preferences_repository.dart';
import 'package:amor_app/features/onboarding/domain/usecases/check_first_run.dart';

class MockPreferencesRepository extends Mock
    implements PreferencesRepository {}

void main() {
  late MockPreferencesRepository mockRepository;
  late CheckFirstRun useCase;

  setUp(() {
    mockRepository = MockPreferencesRepository();
    useCase = CheckFirstRun(mockRepository);
  });

  test('doit renvoyer true quand c\'est le premier lancement', () async {
    when(() => mockRepository.isFirstRun()).thenAnswer((_) async => true);

    final result = await useCase();

    expect(result, isTrue);
    verify(() => mockRepository.isFirstRun()).called(1);
  });

  test('doit renvoyer false quand ce n\'est pas le premier lancement',
      () async {
    when(() => mockRepository.isFirstRun()).thenAnswer((_) async => false);

    final result = await useCase();

    expect(result, isFalse);
  });
}
