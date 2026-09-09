// ============================================================================
// TEST UNITAIRE : CompleteOnboarding (use case)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/onboarding/domain/repositories/preferences_repository.dart';
import 'package:amor_app/features/onboarding/domain/usecases/complete_onboarding.dart';

class MockPreferencesRepository extends Mock
    implements PreferencesRepository {}

void main() {
  late MockPreferencesRepository mockRepository;
  late CompleteOnboarding useCase;

  setUp(() {
    mockRepository = MockPreferencesRepository();
    useCase = CompleteOnboarding(mockRepository);
  });

  test('doit appeler repository.setFirstRunCompleted', () async {
    when(() => mockRepository.setFirstRunCompleted())
        .thenAnswer((_) async {});

    await useCase();

    verify(() => mockRepository.setFirstRunCompleted()).called(1);
  });
}
