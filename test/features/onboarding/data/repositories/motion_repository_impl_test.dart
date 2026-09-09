// ============================================================================
// TEST UNITAIRE : MotionRepositoryImpl
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/onboarding/data/datasources/motion_datasource.dart';
import 'package:amor_app/features/onboarding/data/repositories/motion_repository_impl.dart';

class MockMotionDataSource extends Mock implements MotionDataSource {}

void main() {
  late MockMotionDataSource mockDataSource;
  late MotionRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockMotionDataSource();
    repository = MotionRepositoryImpl(dataSource: mockDataSource);
  });

  test('watchAccelerationMagnitude doit relayer le flux de la datasource',
      () async {
    when(() => mockDataSource.watchAccelerationMagnitude())
        .thenAnswer((_) => Stream.fromIterable([1.0, 3.5, 0.9]));

    final result =
        await repository.watchAccelerationMagnitude().toList();

    expect(result, [1.0, 3.5, 0.9]);
    verify(() => mockDataSource.watchAccelerationMagnitude()).called(1);
  });
}
