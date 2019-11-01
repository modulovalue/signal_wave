import 'package:signal_wave/signal_wave.dart';
import 'package:signal_wave/src/tester/wave_tester.dart';
import 'package:test/test.dart';

import '../streams_in_order.dart';

void main() {
    group("signal_wave.dart", () {
        /// Waves are observables without errors and with a default value
        /// and do somewhat follow the observable spec
        /// Observable spec: https://github.com/ReactiveX/rxjs/blob/master/spec/Observable-spec.ts
        group("$Wave", () {
            test('should be constructed with a subscriber function', () {
                expect(
                    Wave<int>.custom(1, (sink) {
                        sink.add(1);
                        sink.close();
                        return Disposable(() {});
                    }).asStream(),
                    emitsInOrder(<dynamic>[
                        1,
                        emitsDone,
                    ]));
            });
            //   impossible   it('should send errors thrown in the constructor down the error path',
            //   not to spec   it('should allow empty ctor, which is effectively a never-observable', () => {
            //   not to spec   describe('forEach', () => {
            group("subscribe", () {
                test("should be synchronous", () {
                    var subscribed = false;
                    String nexted;
                    bool completed;
                    final source = Wave.custom("", (sink) {
                        subscribed = true;
                        sink.add("wee");
                        expect(nexted, "wee");
                        sink.close();
                        expect(completed, true);
                        return Disposable();
                    });

                    expect(subscribed, false);

                    var mutatedByNext = false;
                    var mutatedByComplete = false;
                    source.subscribe((x) {
                        nexted = x;
                        mutatedByNext = true;
                    }, () {
                        completed = true;
                        mutatedByComplete = true;
                    });

                    expect(mutatedByNext, true);
                    expect(mutatedByComplete, true);
                });
                test('should work when subscribe is called with no arguments', () {
                    final source = Wave.custom("a", (event) {
                        event.add("a");
                        event.close();
                        return Disposable();
                    });
                    source.subscribe();
                });
                test(
                    'should not be unsubscribed when other empty subscription completes',
                        () {
                        var unsubscribeCalled = false;
                        final source = Wave.custom("-", (event) {
                            return Disposable(() {
                                unsubscribeCalled = true;
                            });
                        });
                        source.subscribe();
                        expect(unsubscribeCalled, false);
                        Wave.just("a").subscribe();
                        expect(unsubscribeCalled, false);
                    });
                //  undefined  it('should run unsubscription logic when an error is sent asynchronously and subscribe is called with no arguments', (done) => {
                test(
                    'should return a Subscription that calls the unsubscribe function returned by the subscriber',
                        () {
                        var unsubscribeCalled = false;

                        final source = Wave.custom("", (sink) {
                            return Disposable(() {
                                unsubscribeCalled = true;
                            });
                        });

                        final sub = source.subscribe((_) {});
                        expect(sub is Disposable, true);
                        expect(unsubscribeCalled, false);
                        sub.cancel();
                        expect(unsubscribeCalled, true);
                    });

                test('should ignore next messages after unsubscription', () async {
                    int set;
                    int subSet;
                    Wave<int>.custom(1, (EventSink<int> sink) {
                        sink.add(1);
                        Future<void>.delayed(const Duration(milliseconds: 10))
                            .then<void>((_) {
                            sink.add(2);
                            set = 2;
                        });
                        return Disposable(sink.close);
                    }).subscribe((val) => subSet = val).cancel();
                    await Future<void>.delayed(const Duration(milliseconds: 20));
                    expect(set, 2);
                    expect(subSet, 1);
                });
                //   impossible   it('should ignore error messages after unsubscription', (done) => {
                test('should ignore complete messages after unsubscription', () async {
                    int cancelled = 0;
                    final sub = Wave<int>.custom(1, (EventSink<int> sink) {
                        sink.add(1);
                        Future<void>.delayed(const Duration(milliseconds: 10))
                            .then<void>((_) {
                            sink.close();
                        });
                        return Disposable(sink.close);
                    }).subscribe((val) {}, () => cancelled++);
                    sub.cancel();
                    await Future<void>.delayed(const Duration(milliseconds: 20));
                    expect(cancelled, 1);
                });
            });
            //   undefined   group("'when called with an anonymous observer'", () {
            //   undefined   describe('config.useDeprecatedSynchronousErrorHandling', () => {
            //   undefined   describe('if config.useDeprecatedSynchronousErrorHandling === true', () => {
            //   not to spec   describe('pipe', () => {
        });

        group("ctors/static creators", () {
            test("just", () async {
                final wave = Wave.just(1);
                expect(await wave.asFuture(), const [NextEvent(1), CloseEvent<int>()]);
                expect(await wave.asFuture(), const [NextEvent(1), CloseEvent<int>()]);
            });
            test("empty", () async {
                final wave = Wave<int>.empty();
                expect(await wave.asFuture(), const [CloseEvent<int>()]);
                expect(await wave.asFuture(), const [CloseEvent<int>()]);
            });
            test("of", () async {
                final wave = Wave.fromIterable([100, 101]);
                const result = [NextEvent(100), NextEvent(101), CloseEvent<int>()];
                expect(await wave.asFuture(), result);
                expect(await wave.asFuture(), result);
            });
            test("generate", () async {
                final wave = Wave.generate(2, (int a) => a * 3);
                const result = [NextEvent(0), NextEvent(3), CloseEvent<int>()];
                expect(await wave.asFuture(), result);
                expect(await wave.asFuture(), result);
            });
            test("periodic", () async {
                expectSub(Wave.timer(const Duration(milliseconds: 100), (a) => a).asStream(), emitsInOrder(<dynamic>[
                    0, 1, emitsDone,
                ])).doThenCancel(() async {
                    await Future<void>.delayed(const Duration(milliseconds: 150));
                    return null;
                });
            });
            test("repeat", () async {
                final wave = Wave.repeat(2, 2);
                const result = [NextEvent(2), NextEvent(2), CloseEvent<int>()];
                expect(await wave.asFuture(), result);
                expect(await wave.asFuture(), result);
            });
            test("combineLatestID", () {
                /// TODO
            });
            test("combineLatest", () async {
                final one = Wave.just("a");
                final two = Wave.fromIterable(["a", "ab"]);

                final a = Wave.combineLatest([one, two], (a) => a.join());

                final result = [
                    const NextEvent("aa"),
                    const NextEvent("aab"),
                    const CloseEvent<String>()
                ];

                expect(await a.asFuture(), result);
                expect(await a.asFuture(), result);
            });
            test("combineLatest2 smoke test", () {
                final Signal<String> a = Signal("a");
                final Signal<String> b = Signal("z");

                final sut = a.wave.and(b.wave).latest((String a, String b) => a + b);

                final tester = WaveTester(sut);

                b.add("y");
                a.add("b");
                a.close();
                b.add("x");
                b.close();

                tester.expectCancelDidEmitTAndEnd([
                    "az",
                    "ay",
                    "by",
                    "bx",
                ]);
            });
            test("mapWithWave", () {});
            test("whereWave", () {});
            test("waveWaveWhere", () {});
        });
        group("custom tests", () {
            test("waves have an initial value", () {
                final Wave<int> wave = Wave.just(1);
                expect(wave.value, 1);
            });
            test("transformed waves have a latest, transformed value", () async {
                final signal = Wave.just(10);
                final Wave<int> timesTwo = signal.map((i) => i * 2);
                expect(timesTwo.value, 20);
            });
            test("when a wave finishes itself, its subscribers are notified", () {
                final List<Event<int>> events = [];
                final wave = Wave.fromIterable([1, 2]);
                wave.subscribeSink(EventSink(events.add));
                expect(events, <Event<int>>[const NextEvent(1), const NextEvent(2), const CloseEvent<int>()]);
            });
            test("a cancelled subscription doesn't receive events when there are other active subscriptions", () {
                final List<Event<int>> events1 = [];
                final List<Event<int>> events2 = [];

                final Signal<int> signal = Signal(0);

                final wave = signal.wave;
                final first = wave.subscribeEvent(events1.add);
                final _ = wave.subscribeEvent(events2.add);

                expect(events1, <Event<int>>[const NextEvent(0)]);
                expect(events2, <Event<int>>[const NextEvent(0)]);

                signal.add(1);
                first.cancel();
                signal.add(2);

                signal.close();

                expect(events1, <Event<int>>[const NextEvent(0), const NextEvent(1), const CloseEvent<int>()]);
                expect(
                    events2, <Event<int>>[const NextEvent(0), const NextEvent(1), const NextEvent(2), const CloseEvent<int>()]);
            });
            test("new values are passed to the signals wave", () {
                // ignore: close_sinks
                final signal = Signal(1);
                signal.add(2);
                expect(signal.wave.value, 2);
            });
        });
    });
}