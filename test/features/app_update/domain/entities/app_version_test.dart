// ============================================================================
// TEST UNITAIRE : AppVersion
// ============================================================================
// Lecture des numéros de version et ordre entre versions et préversions.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/app_update/domain/entities/app_version.dart';

AppVersion v(String text) => AppVersion.tryParse(text)!;

void main() {
  group('lecture', () {
    test('doit lire une version simple, avec ou sans "v"', () {
      expect(v('1.2.3').toString(), '1.2.3');
      expect(v('v1.2.3').toString(), '1.2.3');
    });

    test('doit lire une préversion', () {
      final version = v('v1.0.0-beta.2');
      expect(version.isPrerelease, isTrue);
      expect(version.prerelease, ['beta', '2']);
      expect(version.toString(), '1.0.0-beta.2');
    });

    test('doit ignorer le numéro de build', () {
      expect(v('1.0.0-beta.1+2'), v('1.0.0-beta.1'));
      expect(v('1.0.0+7'), v('1.0.0'));
    });

    test('doit refuser ce qui n\'est pas une version', () {
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('1.0'), isNull);
      expect(AppVersion.tryParse('latest'), isNull);
      expect(AppVersion.tryParse('v1.0.0 beta'), isNull);
    });
  });

  group('ordre', () {
    test('doit comparer majeure, mineure puis correctif', () {
      expect(v('1.0.1') > v('1.0.0'), isTrue);
      expect(v('1.1.0') > v('1.0.9'), isTrue);
      expect(v('2.0.0') > v('1.99.99'), isTrue);
      expect(v('1.10.0') > v('1.9.0'), isTrue);
    });

    test('doit placer une préversion avant la version finale', () {
      expect(v('1.0.0-beta.1') < v('1.0.0'), isTrue);
      expect(v('1.0.0') > v('1.0.0-rc.1'), isTrue);
    });

    test('doit comparer les préversions morceau par morceau', () {
      expect(v('1.0.0-beta.2') > v('1.0.0-beta.1'), isTrue);
      expect(v('1.0.0-beta.10') > v('1.0.0-beta.9'), isTrue);
      expect(v('1.0.0-rc.1') > v('1.0.0-beta.5'), isTrue);
      expect(v('1.0.0-beta.1') > v('1.0.0-beta'), isTrue);
      expect(v('1.0.0-beta') > v('1.0.0-1'), isTrue);
    });

    test('doit placer la préversion suivante après la version finale précédente',
        () {
      expect(v('1.1.0-beta.1') > v('1.0.0'), isTrue);
    });

    test('doit considérer égales deux écritures de la même version', () {
      expect(v('v1.0.0'), v('1.0.0'));
      expect(v('1.0.0').compareTo(v('1.0.0')), 0);
    });
  });
}
