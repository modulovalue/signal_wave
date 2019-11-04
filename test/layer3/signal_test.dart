// ignore_for_file: close_sinks
import 'package:dartz/dartz.dart';
import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';

void main() {
  group("signal.dart", () {
    test("starts out with a value", () {
      final sut = Signal<int>(1);
      expect(sut.value, 1);
    });
    test("isClosed is true when signal was cancelled", () {
      final sut = Signal<int>(1);
      expect(sut.isClosed, false);
      sut.close();
      expect(sut.isClosed, true);
    });
    test("transformed signals have transformed the initial value", () async {
      final signal = Signal(10);
      final Wave<int> timesTwo = signal.wave.map((i) => i * 2);
      expect(timesTwo.value, 20);
    });
    test("setting a value changes the value", () {
      final sut = Signal<int>(1);
      sut <= 2;
      expect(sut.value, 2);
    });
    test("setting a value on a closed signal throws", () {
      final sut = Signal<int>(1);
      sut.close();
      expect(() => sut <= 2, throwsException);
    });
    test("initial value is passed to new subscribers", () {
      final sut = Signal<int>(1);
      int a;
      int b;
      final wave = sut.wave;
      wave.subscribe((int i) => a = i, () => throw Exception("-"));
      wave.subscribe((int i) => b = i, () => throw Exception("-"));
      expect(a, 1);
      expect(b, 1);
      expect(wave.value, 1);
    });
    test("new value is passed to listeners", () {
      final sut = Signal<int>(1);
      int a;
      int b;
      final wave = sut.wave;
      wave.subscribe((int i) => a = i, () => throw Exception("-"));
      wave.subscribe((int i) => b = i, () => throw Exception("-"));
      sut.add(2);
      expect(a, 2);
      expect(b, 2);
      expect(wave.value, 2);
    });
    test(
        "not subscribed waves keep their initial value which isn't updated if they are not subscribed to",
        () {
      final sut = Signal<int>(1);
      final wave = sut.wave;
      sut.add(2);
      expect(sut.value, 2);
      expect(wave.value, 1);
    });
    test("new subscribers receive newly added values", () {
      final sut = Signal<int>(1);
      sut.add(2);
      int a;
      int b;
      sut.wave.subscribe((int i) => a = i, () => throw Exception("-"));
      sut.wave.subscribe((int i) => b = i, () => throw Exception("-"));
      expect(a, 2);
      expect(b, 2);
    });
    test("closing the signal cancels all subscriptions", () {
      final sut = Signal<int>(1);
      bool cancelleda = false;
      bool cancelledb = false;
      sut.wave.subscribe((int a) {}, () => cancelleda = true);
      sut.wave.subscribe((int a) {}, () => cancelledb = true);
      expect(cancelleda, false);
      expect(cancelledb, false);
      expect(sut.isClosed, false);
      sut.close();
      expect(cancelleda, true);
      expect(cancelledb, true);
      expect(sut.isClosed, true);
    });
    test("subscriptions on a closed signal are allowed", () {
      final sut = Signal<int>(1);
      sut.close();
      final List<Event<int>> events = [];
      final _ = sut.wave.subscribeEvent(events.add);
      expect(events, <Event<int>>[]);
    });
    test("Adding a value to a closed signal throws", () {
      final sut = Signal<int>(1);
      sut.close();
      expect(() => sut.add(11), throwsA(const TypeMatcher<Exception>()));
    });
    test("onCancel is called when the last subscriber unsubscribes", () {
      bool cancelled = false;
      final sut = Signal<int>(2, onCancel: () => cancelled = true);
      expect(cancelled, false);
      final dispose1 = sut.wave.subscribe();
      final dispose2 = sut.wave.subscribe();
      expect(cancelled, false);
      dispose1.cancel();
      expect(cancelled, false);
      dispose2.cancel();
      expect(cancelled, true);
    });
    test("the signal is not closed when the last subscriber unsubscribes", () {
      final sut = Signal<int>(2);
      expect(sut.isClosed, false);
      final dispose1 = sut.wave.subscribe();
      final dispose2 = sut.wave.subscribe();
      expect(sut.isClosed, false);
      dispose1.cancel();
      expect(sut.isClosed, false);
      dispose2.cancel();
      expect(sut.isClosed, false);
    });
    test("the signal shares whether is has subscribers", () {
      final sut = Signal<int>(2);
      expect(sut.hasSubscribers, false);
      final dispose1 = sut.wave.subscribe();
      expect(sut.hasSubscribers, true);
      final dispose2 = sut.wave.subscribe();
      expect(sut.hasSubscribers, true);
      dispose1.cancel();
      expect(sut.hasSubscribers, true);
      dispose2.cancel();
      expect(sut.hasSubscribers, false);
    });
    test("hasSubscribers is true inside the onListen method", () {
      final List<bool> hasSubscribers = [];
      Signal<int> sut;
      sut = Signal<int>(2,
          onListen: () => hasSubscribers.add(sut.hasSubscribers));
      expect(hasSubscribers, <dynamic>[]);
      sut.wave.subscribe();
      expect(hasSubscribers, <dynamic>[true]);
    });
    test(
        "hasSubscribers is false inside the onCancel method when the last subscription was cancelled",
        () {
      final List<bool> hasSubscribers = [];
      Signal<int> sut;
      sut = Signal<int>(2,
          onCancel: () => hasSubscribers.add(sut.hasSubscribers));
      expect(hasSubscribers, <dynamic>[]);
      final sub = sut.wave.subscribe();
      final sub2 = sut.wave.subscribe();
      sub.cancel();
      sub2.cancel();
      expect(hasSubscribers, <dynamic>[false]);
    });
    test(
        "hasSubscribers is false inside the onCancel method when the signal was closed with listeners",
        () {
      final List<bool> hasSubscribers = [];
      Signal<int> sut;
      sut = Signal<int>(2,
          onCancel: () => hasSubscribers.add(sut.hasSubscribers));
      expect(hasSubscribers, <dynamic>[]);
      // ignore: unused_local_variable
      final sub = sut.wave.subscribe();
      sut.close();
      expect(hasSubscribers, <dynamic>[false]);
    });
    test("dont call onCancel when the signals is closed with no listeners", () {
      final List<bool> hasSubscribers = [];
      Signal<int> sut;
      sut = Signal<int>(2,
          onCancel: () => hasSubscribers.add(sut.hasSubscribers));
      expect(hasSubscribers, <dynamic>[]);
      sut.close();
      expect(hasSubscribers, <dynamic>[]);
    });
    test("add operator", () {
      final sut = Signal<int>(1);
      final plusOne = sut.wave.map((a) => a + 1);
      final plusTwo = sut.wave.map((a) => a + 2);

      plusOne.subscribe();
      plusTwo.subscribe();

      expect(sut.value, 1);
      expect(plusOne.value, 2);
      expect(plusTwo.value, 3);
      sut <= 2;
      expect(sut.value, 2);
      expect(plusOne.value, 3);
      expect(plusTwo.value, 4);
      sut <= 3;
      expect(sut.value, 3);
      expect(plusOne.value, 4);
      expect(plusTwo.value, 5);

      sut.close();
    });
    test("can emit values inside of onListen", () {
      Signal<Option<int>> signal;

      signal = Signal<Option<int>>(None(), onListen: () {
        signal.add(Some(2));
      });

      final List<Event<Option<int>>> events = [];

      signal.wave.subscribeEvent(events.add);

      signal.close();

      expect(events, [
        NextEvent<Option<int>>(None()),
        NextEvent<Option<int>>(Some(2)),
        const CloseEvent<Option<int>>(),
      ]);
    });
    test(
        "a cancelled wave doesn't make the subscription receive a closed event",
        () async {
      final Signal<String> signal = Signal("0");

      final wave = signal.wave;

      final List<String> received = [];

      final subscriptionDirect1 = signal.wave.subscribe((val) {
        received.add("a-received-$val");
      }, () {
        received.add("a-closed");
      });

      final subscriptionDirect2 = signal.wave.subscribe((val) {
        received.add("b-received-$val");
      }, () {
        received.add("b-closed");
      });

      final subscriptionReference1 = wave.subscribe((val) {
        received.add("c-received-$val");
      }, () {
        received.add("c-closed");
      });

      final subscriptionReference2 = signal.wave.subscribe((val) {
        received.add("d-received-$val");
      }, () {
        received.add("d-closed");
      });

      signal.add("1");
      signal.add("2");
      subscriptionDirect1.cancel();
      subscriptionDirect2.cancel();
      subscriptionReference1.cancel();
      subscriptionReference2.cancel();

      expect(received, [
        "a-received-0",
        "b-received-0",
        "c-received-0",
        "d-received-0",
        "a-received-1",
        "b-received-1",
        "c-received-1",
        "d-received-1",
        "a-received-2",
        "b-received-2",
        "c-received-2",
        "d-received-2",
        "a-closed",
        "b-closed",
        "c-closed",
        "d-closed",
      ]);
    });
    test("a cancelled wave doesn't cancel the underlying signal", () async {
      final Signal<String> signal = Signal("0");

      final List<String> received = [];

      final sub1 = signal.wave.subscribe((val) {
        received.add("a-received-$val");
      }, () {
        received.add("a-closed");
      });

      signal.add("1");

      sub1.cancel();

      final sub2 = signal.wave.subscribe((val) {
        received.add("b-received-$val");
      }, () {
        received.add("b-closed");
      });

      signal.add("2");

      sub2.cancel();

      signal.add("3");

      expect(received, [
        "a-received-0",
        "a-received-1",
        "a-closed",
        "b-received-1",
        "b-received-2",
        "b-closed",
      ]);
    });
  });
}
