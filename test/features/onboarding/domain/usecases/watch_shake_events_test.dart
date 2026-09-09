// ============================================================================
// TEST UNITAIRE : WatchShakeEvents (use case)
// ============================================================================
// Ce use case contient de la vraie logique métier (seuil de détection +
// anti-rebond de 500ms) : on la teste directement plutôt que de se
// contenter de vérifier la délégation au repository.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:amor_app/features/onboarding/domain/repositories/motion_repository.dart';
import 'package:amor_app/features/onboarding/domain/usecases/watch_shake_events.dart';

class MockMotionRepository extends Mock implements MotionRepository {}

void main() {
  late MockMotionRepository mockRepository;
  late WatchShakeEvents useCase;
  late StreamController<double> controller;

  setUp(() {
    mockRepository = MockMotionRepository();
    controller = StreamController<double>.broadcast();
    when(() => mockRepository.watchAccelerationMagnitude())
        .thenAnswer((_) => controller.stream);
    useCase = WatchShakeEvents(mockRepository);
  });

  tearDown(() => controller.close());

  test('ne doit rien émettre pour une accélération sous le seuil (2.7)',
      () async {
    final emitted = <void>[];
    final sub = useCase().listen(emitted.add);

    controller.add(1.0);
    controller.add(2.5);
    controller.add(2.7); // égal au seuil : exclu (strictement supérieur requis)
    await Future.delayed(Duration.zero);

    expect(emitted, isEmpty);
    await sub.cancel();
  });

  test('doit émettre un événement pour une secousse au-dessus du seuil',
      () async {
    final emitted = <void>[];
    final sub = useCase().listen(emitted.add);

    controller.add(3.0);
    await Future.delayed(Duration.zero);

    expect(emitted.length, 1);
    await sub.cancel();
  });

  test('doit ignorer les secousses trop rapprochées (anti-rebond 500ms)',
      () async {
    final emitted = <void>[];
    final sub = useCase().listen(emitted.add);

    controller.add(3.0);
    controller.add(3.2);
    controller.add(4.0);
    await Future.delayed(Duration.zero);

    expect(emitted.length, 1);
    await sub.cancel();
  });

  test('doit accepter une nouvelle secousse après le délai anti-rebond',
      () async {
    final emitted = <void>[];
    final sub = useCase().listen(emitted.add);

    controller.add(3.0);
    await Future.delayed(const Duration(milliseconds: 600));
    controller.add(3.1);
    await Future.delayed(Duration.zero);

    expect(emitted.length, 2);
    await sub.cancel();
  });
}
