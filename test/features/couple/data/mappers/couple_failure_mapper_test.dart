// ============================================================================
// TEST UNITAIRE : coupleFailureReasonFromCode
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/couple/data/mappers/couple_failure_mapper.dart';
import 'package:amor_app/features/couple/domain/entities/couple_failure.dart';

void main() {
  test('traduit les codes des Cloud Functions', () {
    expect(coupleFailureReasonFromCode('not-found'),
        CoupleFailureReason.invalidCode);
    expect(coupleFailureReasonFromCode('already-exists'),
        CoupleFailureReason.alreadyInCouple);
    expect(coupleFailureReasonFromCode('invalid-argument'),
        CoupleFailureReason.invalidProfile);
    expect(coupleFailureReasonFromCode('unauthenticated'),
        CoupleFailureReason.notSignedIn);
  });

  test('les coupures réseau donnent network', () {
    expect(coupleFailureReasonFromCode('unavailable'),
        CoupleFailureReason.network);
    expect(coupleFailureReasonFromCode('deadline-exceeded'),
        CoupleFailureReason.network);
  });

  test('un code inconnu donne unknown', () {
    expect(coupleFailureReasonFromCode('permission-denied'),
        CoupleFailureReason.unknown);
  });
}
