// ============================================================================
// MOTION REPOSITORY (IMPLEMENTATION)
// ============================================================================

import '../../domain/repositories/motion_repository.dart';
import '../datasources/motion_datasource.dart';

class MotionRepositoryImpl implements MotionRepository {
  final MotionDataSource _dataSource;

  const MotionRepositoryImpl({required MotionDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<double> watchAccelerationMagnitude() =>
      _dataSource.watchAccelerationMagnitude();
}