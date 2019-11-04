import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:signal_wave/signal_wave.dart';

Wave<S> justWave<S>(S value) {
  return Wave.custom(value, (EventSink<S> sink) {
    /// Just is implicit by providing the initial value.
    sink.add(value);
    sink.close();
    return Disposable();
  });
}

Wave<S> emptyWave<S>([S value]) {
  return Wave<S>.custom(value, (EventSink<S> sink) {
    sink.close();
    return Disposable();
  });
}

Wave<S> fromIterableWave<S>(Iterable<S> collection) {
  return Wave.custom(collection.isEmpty ? null : collection.first,
      (EventSink<S> sink) {
    collection.forEach(sink.add);
    sink.close();
    return Disposable();
  });
}

Wave<Option<Either<dynamic, S>>> fromStreamWave<S>(Stream<S> stream) {
  return Wave.custom(None(), (EventSink<Option<Either<dynamic, S>>> sink) {
    sink.add(None());
    final sub = stream.listen((data) => sink.add(Some(Right<dynamic, S>(data))),
        onError: (dynamic err) {
          sink.add(Some(Left<dynamic, S>(err)));
          sink.close();
        },
        onDone: () => sink.close(),
        cancelOnError: false);
    return Disposable(sub.cancel);
  });
}

/// Starts with 0
Wave<S> generateWave<S>(int times, S Function(int index) map) {
  final initial = times == 0 ? null : map(0);
  return Wave.custom(initial, (EventSink<S> sink) {
    List.generate(times, (i) => sink.add((i > 0) ? map(i) : initial));
    sink.close();
    return Disposable();
  });
}

Wave<S> periodic<S>(Duration duration, S Function(int) valueComputation) {
  final initial = valueComputation(0);
  return Wave.custom(initial, (EventSink<S> sink) {
    Disposable disposable;

    sink.add(initial);

    final subscription =
        Stream<S>.periodic(duration, (a) => valueComputation(a + 1)).listen(
      (a) {
        if (disposable != null && !disposable.isDisposed) sink.add(a);
      },
      onError: (dynamic err) => disposable.cancel(),
      onDone: () {
        disposable.cancel();
      },
    );

    // disposable is being kept track of
    return disposable = Disposable(() {
      subscription.cancel();
      sink.close();
    });
  });
}

Wave<S> repeatWave<S>(int times, S value) {
  return Wave.generate(times, (_) => value);
}
