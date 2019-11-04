import 'package:pedantic/pedantic.dart';
import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';

void main() {
  group("other.dart", () {
    group("asFuture", () {
      test("completes", () async {
        final wave = Wave.fromIterable([1, 2]);
        expect(await wave.asFuture(), <dynamic>[
          const NextEvent<int>(1),
          const NextEvent<int>(2),
          const CloseEvent<int>(),
        ]);
      });
    });
    group("oneAsFuture", () {
      test("will immediately finish because signals have a value", () async {
        final wave = Wave.fromIterable([1, 2]);
        expect(
            wave.oneAsFuture().asStream(),
            emitsInOrder(<dynamic>[
              const NextEvent<int>(1),
              emitsDone,
            ]));
      });
    });
    group("nextAsFuture", () {
      test("will finish on next value", () async {
        // ignore: close_sinks
        final wave = Wave.fromIterable([1, 2]);
        expect(
            wave.nextAsFuture().asStream(),
            emitsInOrder(<dynamic>[
              const NextEvent<int>(2),
              emitsDone,
            ]));
      });

      test("gets next value only", () async {
        // ignore: close_sinks
        final signal = Signal(1);
        Event<int> value;
        unawaited(signal.wave.nextAsFuture().then((a) => value = a));
        await pumpEventQueue();
        expect(value, null);
        signal.add(2);
        await pumpEventQueue();
        expect(value, const NextEvent(2));
      });

      test("doesn't listen on signal anymore when done", () async {
        // ignore: close_sinks
        final signal = Signal(1);

        unawaited(signal.wave.nextAsFuture());

        expect(signal.hasSubscribers, true);
        signal.add(2);
        await pumpEventQueue();
        expect(signal.hasSubscribers, false);
      });
    });
    group("asStream", () {
      test("emits done when wave is done", () {
        expect(Wave.fromIterable([1, 2, 3]).asStream(),
            emitsInOrder(<dynamic>[1, 2, 3, emitsDone]));
      });
      test("signal emits value immediately", () async {
        // ignore: close_sinks
        final Signal<int> signal = Signal(1);
        final List<Object> data = [];
        signal.wave.asStream().listen(data.add, onDone: () => data.add("done"));
        await pumpEventQueue();
        expect(data, <dynamic>[1]);
      });
      test("signal behaves like a regular stream when first element is skipped",
          () async {
        final Signal<int> signal = Signal(1);
        final List<Object> data = [];
        // ignore: cancel_subscriptions
        signal.wave
            .skip(1)
            .asStream()
            .listen(data.add, onDone: () => data.add("done"));
        signal.add(2);
        signal.close();
        await pumpEventQueue();
        expect(data, <dynamic>[2, "done"]);
      });
      test("is not a broadcast stream", () {
        expect(Wave.just(1).asStream().isBroadcast, false);
      });
    });
    group("asBroadcastStream", () {
      test("is a broadcast stream", () {
        expect(Wave.just(1).asBroadcastStream().isBroadcast, true);
      });
    });
  });
}
