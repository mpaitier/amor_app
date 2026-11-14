// ============================================================================
// TEST UNITAIRE : switchMapStream
// ============================================================================

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/core/utils/stream_switch_map.dart';

void main() {
  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('relaie les valeurs du flux intérieur', () async {
    final source = StreamController<int>();
    final values = <String>[];
    final subscription = switchMapStream<int, String>(
      source.stream,
      (value) => Stream.value('valeur $value'),
    ).listen(values.add);

    source.add(1);
    await flush();

    expect(values, ['valeur 1']);
    await subscription.cancel();
    await source.close();
  });

  test('abandonne le flux précédent quand la source change', () async {
    final source = StreamController<String>();
    final first = StreamController<int>();
    final second = StreamController<int>();
    final inners = {'a': first, 'b': second};
    final values = <int>[];

    final subscription = switchMapStream<String, int>(
      source.stream,
      (key) => inners[key]!.stream,
    ).listen(values.add);

    source.add('a');
    await flush();
    first.add(1);
    await flush();

    source.add('b');
    await flush();
    first.add(2); // --- ignoré : "a" n'est plus écouté ---
    second.add(3);
    await flush();

    expect(values, [1, 3]);
    expect(first.hasListener, isFalse);

    await subscription.cancel();
    await source.close();
    await first.close();
    await second.close();
  });

  test('relaie les erreurs du flux intérieur', () async {
    final source = StreamController<int>();
    final errors = <Object>[];
    final subscription = switchMapStream<int, int>(
      source.stream,
      (_) => Stream<int>.error(Exception('refusé')),
    ).listen((_) {}, onError: errors.add);

    source.add(1);
    await flush();

    expect(errors, hasLength(1));
    await subscription.cancel();
    await source.close();
  });

  test('se désabonne de tout à l\'annulation', () async {
    final source = StreamController<int>();
    final inner = StreamController<int>();
    final subscription = switchMapStream<int, int>(
      source.stream,
      (_) => inner.stream,
    ).listen((_) {});

    source.add(1);
    await flush();
    await subscription.cancel();

    expect(source.hasListener, isFalse);
    expect(inner.hasListener, isFalse);
    await source.close();
    await inner.close();
  });
}
