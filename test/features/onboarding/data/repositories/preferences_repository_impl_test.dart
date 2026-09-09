// ============================================================================
// TEST UNITAIRE : PreferencesRepositoryImpl
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/onboarding/data/datasources/preferences_local_datasource.dart';
import 'package:amor_app/features/onboarding/data/repositories/preferences_repository_impl.dart';

class MockPreferencesLocalDataSource extends Mock
    implements PreferencesLocalDataSource {}

void main() {
  late MockPreferencesLocalDataSource mockDataSource;
  late PreferencesRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockPreferencesLocalDataSource();
    repository =
        PreferencesRepositoryImpl(localDataSource: mockDataSource);
  });

  test('isFirstRun doit déléguer à la source locale', () async {
    when(() => mockDataSource.isFirstRun()).thenAnswer((_) async => true);

    final result = await repository.isFirstRun();

    expect(result, isTrue);
    verify(() => mockDataSource.isFirstRun()).called(1);
  });

  test('setFirstRunCompleted doit déléguer à la source locale', () async {
    when(() => mockDataSource.setFirstRunCompleted())
        .thenAnswer((_) async {});

    await repository.setFirstRunCompleted();

    verify(() => mockDataSource.setFirstRunCompleted()).called(1);
  });
}
