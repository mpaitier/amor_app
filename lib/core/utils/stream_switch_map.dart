// ============================================================================
// STREAM SWITCH MAP
// ============================================================================
// À chaque valeur du flux source, ouvre un nouveau flux et abandonne le
// précédent. Sert par exemple à suivre le document d'une relation qui
// change quand la personne en rejoint une autre. asyncExpand ne convient
// pas : il attend la fin du flux intérieur avant de passer au suivant.

import 'dart:async';

Stream<R> switchMapStream<T, R>(
  Stream<T> source,
  Stream<R> Function(T value) mapper,
) {
  late final StreamController<R> controller;
  StreamSubscription<T>? outerSubscription;
  StreamSubscription<R>? innerSubscription;

  controller = StreamController<R>(
    onListen: () {
      outerSubscription = source.listen(
        (value) {
          innerSubscription?.cancel();
          innerSubscription = mapper(value).listen(
            controller.add,
            onError: controller.addError,
          );
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      await innerSubscription?.cancel();
      await outerSubscription?.cancel();
    },
  );

  return controller.stream;
}
