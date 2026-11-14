// ============================================================================
// TEST UNITAIRE : AppUserModel
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/auth/data/models/app_user_model.dart';

class MockUser extends Mock implements User {}

void main() {
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('uid-1');
  });

  test('doit reprendre uid, e-mail et nom affiché', () {
    when(() => mockUser.email).thenReturn('lulu@amor.fr');
    when(() => mockUser.displayName).thenReturn('Lulu');

    final model = AppUserModel.fromFirebaseUser(mockUser);

    expect(model.uid, 'uid-1');
    expect(model.email, 'lulu@amor.fr');
    expect(model.displayName, 'Lulu');
  });

  test('doit remplacer les valeurs absentes par des chaînes vides', () {
    when(() => mockUser.email).thenReturn(null);
    when(() => mockUser.displayName).thenReturn(null);

    final model = AppUserModel.fromFirebaseUser(mockUser);

    expect(model.email, '');
    expect(model.displayName, '');
  });
}
