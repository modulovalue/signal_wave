import 'package:dartz/dartz.dart';
import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';

void main() {
    group("operators.dart", () {
        test("map", () async {
            final wave = Wave.just(1).map((i) => i * 2);
            const result = [NextEvent(2), CloseEvent<int>()];
            expect(await wave.asFuture(), result);
            expect(await wave.asFuture(), result);
        });
        group("futureMap", () {
            test("simple test", () async {
                // ignore: close_sinks
                final Signal<int> signal = Signal(0);

                final List<Tuple2<int, int>> delays = [
                    const Tuple2(100, 1),
                ];

                final Wave<int> wave = signal.wave.futureMap(1, (val) async {
                    final entry = delays.removeAt(0);
                    await Future<void>.delayed(Duration(milliseconds: entry.value1));
                    return entry.value2;
                });

                final List<int> results = [];

                wave.subscribe(results.add);

                await Future<void>.delayed(const Duration(milliseconds: 1000));

                expect(results, <int>[1]);
            });
            test("previous calculation is cancelled", () async {
                // ignore: close_sinks
                final Signal<int> signal = Signal(0);

                final List<Tuple2<int, int>> delays = [
                    const Tuple2(100, 1),
                    const Tuple2(500, 2),
                    const Tuple2(200, 3),
                ];

                final Wave<int> wave = signal.wave.futureMap(1, (val) async {
                    final entry = delays.removeAt(0);
                    await Future<void>.delayed(Duration(milliseconds: entry.value1));
                    return entry.value2;
                });

                final List<int> results = [];

                wave.subscribe(results.add);
                signal.add(0);
                signal.add(0);

                await Future<void>.delayed(const Duration(milliseconds: 1000));

                expect(results, <int>[3]);
            });
            test("finished calculation is passed", () async {
                // ignore: close_sinks
                final Signal<int> signal = Signal(0);

                final List<Tuple2<int, int>> delays = [
                    const Tuple2(100, 1),
                    const Tuple2(500, 2),
                    const Tuple2(200, 3),
                    const Tuple2(800, 4),
                ];

                final Wave<int> wave = signal.wave.futureMap(1, (val) async {
                    final entry = delays.removeAt(0);
                    await Future<void>.delayed(Duration(milliseconds: entry.value1));
                    return entry.value2;
                });

                final List<int> results = [];

                wave.subscribe(results.add);
                signal.add(0);
                signal.add(0);
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                signal.add(0);
                await Future<void>.delayed(const Duration(milliseconds: 1000));

                expect(results, <int>[3, 4]);
            });
            test("all passed calculations are passed", () async {
                // ignore: close_sinks
                final Signal<int> signal = Signal(0);

                final List<Tuple2<int, int>> delays = [
                    const Tuple2(100, 1),
                    const Tuple2(500, 2),
                    const Tuple2(200, 3),
                    const Tuple2(800, 4),
                ];

                final Wave<int> wave = signal.wave.futureMap(1, (val) async {
                    final entry = delays.removeAt(0);
                    await Future<void>.delayed(Duration(milliseconds: entry.value1));
                    return entry.value2;
                });

                final List<int> results = [];

                wave.subscribe(results.add);
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                signal.add(0);
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                signal.add(0);
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                signal.add(0);
                await Future<void>.delayed(const Duration(milliseconds: 1000));

                expect(results, <int>[1, 2, 3, 4]);
            });
            test("disposed signal doesn't pass data on", () async {
                // ignore: close_sinks
                final Signal<int> signal = Signal(0);

                final List<Tuple2<int, int>> delays = [
                    const Tuple2(100, 1),
                ];

                final Wave<int> wave = signal.wave.futureMap(1, (val) async {
                    final entry = delays.removeAt(0);
                    await Future<void>.delayed(Duration(milliseconds: entry.value1));
                    return entry.value2;
                });

                final List<int> results = [];

                wave.subscribe(results.add);
                signal.close();

                await Future<void>.delayed(const Duration(milliseconds: 500));

                expect(results, <int>[]);
            });
            test("act as delay for data calculation", () async {
                // ignore: close_sinks
                final Signal<int> signal = Signal(0);

                final Wave<int> wave = signal.wave.futureMap(1, (val) async {
                    await Future<void>.delayed(const Duration(milliseconds: 500));
                    return val;
                }).map((a) {
                    return a + 3;
                });

                final List<int> results = [];

                expect(results, <int>[]);
                wave.subscribe(results.add);
                expect(results, <int>[]);
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                expect(results, <int>[0 + 3]);
                signal.add(10);
                expect(results, <int>[0 + 3]);
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                expect(results, <int>[0 + 3, 10 + 3]);
            });
        });
        group("take", () {
            test("take 0 wave", () async {
                final wave = Wave.fromIterable([1, 2, 3]).take(0);
                expect(wave.asStream(), emitsInOrder(<dynamic>[emitsDone]));
                expect(wave.asStream(), emitsInOrder(<dynamic>[emitsDone]));
            });
            test("take 1 wave", () async {
                final wave = Wave.fromIterable([1, 2, 3]).take(1);
                expect(wave.asStream(), emitsInOrder(<dynamic>[1, emitsDone]));
                expect(wave.asStream(), emitsInOrder(<dynamic>[1, emitsDone]));
            });
            test("take 2 wave", () async {
                final wave = Wave.fromIterable([1, 2, 3]).take(2);
                expect(wave.asStream(), emitsInOrder(<dynamic>[1, 2, emitsDone]));
                expect(wave.asStream(), emitsInOrder(<dynamic>[1, 2, emitsDone]));
            });
        });
        group("skip", () {
            test("skip 0", () async {
                final wave = Wave.fromIterable([1, 2, 3]).skip(0);
                expect(wave.asStream(), emitsInOrder(<dynamic>[1, 2, 3, emitsDone]));
                expect(wave.asStream(), emitsInOrder(<dynamic>[1, 2, 3, emitsDone]));
            });
            test("skip 1", () async {
                final wave = Wave.fromIterable([1, 2, 3]).skip(1);
                expect(wave.asStream(), emitsInOrder(<dynamic>[2, 3, emitsDone]));
                expect(wave.asStream(), emitsInOrder(<dynamic>[2, 3, emitsDone]));
            });
            test("skip 2", () async {
                final wave = Wave.fromIterable([1, 2, 3]).skip(2);
                expect(wave.asStream(), emitsInOrder(<dynamic>[3, emitsDone]));
                expect(wave.asStream(), emitsInOrder(<dynamic>[3, emitsDone]));
            });
            test("skip too many finishes immediately", () async {
                final wave = Wave.fromIterable([1, 2, 3]).skip(99);
                expect(wave.asStream(), emitsInOrder(<dynamic>[emitsDone]));
                expect(wave.asStream(), emitsInOrder(<dynamic>[emitsDone]));
            });
        });
        test("take and skip", () async {
            final wave = Wave.fromIterable([1, 2, 3]).skip(1).take(1);
            const result = [NextEvent(2), CloseEvent<int>()];
            expect(await wave.asFuture(), result);
            expect(await wave.asFuture(), result);
        });
        group("flatMap", () {
            test("a:C b:NC", () {
                final List<Event<int>> events = [];
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.flatMap((a) => b.wave).subscribeEvent(events.add);
                a.close();
                expect(events, [
                    const NextEvent(2),
                ]);
            });

            test("1. a:C b:C", () {
                final List<Event<int>> events = [];
                final Signal<int> a = Signal(1);
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.flatMap((a) => b.wave).subscribeEvent(events.add);
                b.close();
                a.close();
                expect(events, [
                    const NextEvent(2),
                    const CloseEvent<int>(),
                ]);
            });

            test("2. a:C b:C", () {
                final List<Event<int>> events = [];
                final Signal<int> a = Signal(1);
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.flatMap((a) => b.wave).subscribeEvent(events.add);
                a.close();
                b.close();
                expect(events, [
                    const NextEvent(2),
                    const CloseEvent<int>(),
                ]);
            });

            test("a:NC b:C", () {
                final List<Event<int>> events = [];
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.flatMap((a) => b.wave).subscribeEvent(events.add);
                b.close();
                expect(events, [
                    const NextEvent(2),
                ]);
            });

            test("a:NC b:NC", () {
                final List<Event<int>> events = [];
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.flatMap((a) => b.wave).subscribeEvent(events.add);
                expect(events, [
                    const NextEvent(2),
                ]);
            });

            test("closing sub", () {
                final List<Event<int>> events = [];
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(2);
                final Disposable sub = a.wave.flatMap((a) => b.wave).subscribeEvent(events.add);
                sub.cancel();
                expect(events, [
                    const NextEvent(2),
                    const CloseEvent<int>(),
                ]);
            });

            /// Typescript template for validation:
            ///
            /// ```ts
            /// console.clear();
            /// import { of, combineLatest, BehaviorSubject } from 'rxjs';
            /// import { switchMap, flatMap } from 'rxjs/operators';
            ///
            ///
            /// const a = new BehaviorSubject(1);
            /// const a1 = new BehaviorSubject(10);
            ///
            /// const a2 = new BehaviorSubject(100);
            ///
            /// const x = a
            /// .pipe(
            ///   flatMap((a) => (a == 1 ? a1 : a2))
            /// );
            /// x.subscribe(
            ///   (a) => console.log(`emit: ${a}`),
            ///   (err) => console.log(err),
            ///   () => console.log("done"),
            ///  );
            ///
            /// ```
            /// Only closes when all participating streams close
            test("flatMap behavior like rxjs", () {
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(10);
                // ignore: close_sinks
                final Signal<int> c = Signal(100);

                final Wave<int> awave = a.wave;
                final Wave<int> bwave = b.wave;
                final Wave<int> cwave = c.wave;

                final Wave<int> flatmapped = awave.flatMap<int>((i) => (i == 1) ? bwave : cwave);

                final List<Event<int>> events = [];

                awave.subscribeSink(EventSink((a) => events.add(KeyedEvent("a", a))));
                bwave.subscribeSink(EventSink((a) => events.add(KeyedEvent("b", a))));
                cwave.subscribeSink(EventSink((a) => events.add(KeyedEvent("c", a))));
                flatmapped.subscribeSink(EventSink((a) => events.add(KeyedEvent("fm", a))));

                b <= 20;
                a <= 2;
                c <= 200;
                b <= 30;

                c.close();
                a.close();
                b.close();

                expect(events, <dynamic>[
                    // init
                    const KeyedEvent("a", NextEvent(1)),
                    const KeyedEvent("b", NextEvent(10)),
                    const KeyedEvent("c", NextEvent(100)),
                    const KeyedEvent("fm", NextEvent(10)),
                    // test b
                    const KeyedEvent("b", NextEvent(20)),
                    const KeyedEvent("fm", NextEvent(20)),
                    // switch to c
                    const KeyedEvent("a", NextEvent(2)),
                    const KeyedEvent("fm", NextEvent(100)),
                    // test c
                    const KeyedEvent("c", NextEvent(200)),
                    const KeyedEvent("fm", NextEvent(200)),
                    // flatmap behavior: flatmap is still subscribed to b
                    const KeyedEvent("b", NextEvent(30)),
                    const KeyedEvent("fm", NextEvent(30)),
                    // closing
                    const KeyedEvent("c", CloseEvent<int>()),
                    const KeyedEvent("a", CloseEvent<int>()),
                    const KeyedEvent("b", CloseEvent<int>()),
                    const KeyedEvent("fm", CloseEvent<int>()),
                ]);
            });
            test("cancelled flatmap doesn't receive any new events", () {
                final Signal<int> a = Signal(1);
                final Signal<int> b = Signal(10);
                final Signal<int> c = Signal(100);

                final Wave<int> awave = a.wave;
                final Wave<int> bwave = b.wave;
                final Wave<int> cwave = c.wave;

                final Wave<int> flatmapped = awave.flatMap<int>((i) => (i == 1) ? bwave : cwave);

                final List<Event<int>> events = [];

                flatmapped.subscribeSink(EventSink((a) => events.add(KeyedEvent("fm", a)))).cancel();

                b <= 20;
                a <= 2;
                c <= 200;
                b <= 30;

                c.close();
                a.close();
                b.close();

                expect(events, <dynamic>[
                    const KeyedEvent("fm", NextEvent(10)),
                    const KeyedEvent("fm", CloseEvent<int>()),
                ]);
            });

            test("cancelling a flatMap does remove all subscribers from the sources", () {
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(10);

                final List<Event<int>> events = [];

                final c = a.wave.flatMap((_) => b.wave);

                final sub = c.subscribeEvent(events.add);

                expect(a.countSubscribers, 1);
                expect(b.countSubscribers, 1);
                sub.cancel();
                expect(a.countSubscribers, 0);
                expect(b.countSubscribers, 0);
            });
        });
        group("switchMap", () {
            test("a:C b:NC", () {
                final List<Event<int>> events = [];
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.switchMap((a) => b.wave).subscribeEvent(events.add);
                a.close();
                expect(events, [
                    const NextEvent(2),
                ]);
            });

            test("1: a:C b:C", () {
                final List<Event<int>> events = [];
                final Signal<int> a = Signal(1);
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.switchMap((a) => b.wave).subscribeEvent(events.add);
                a.close();
                b.close();
                expect(events, [
                    const NextEvent(2),
                    const CloseEvent<int>(),
                ]);
                expect(a.hasSubscribers, false);
                expect(b.hasSubscribers, false);
            });

            test("2: a:C b:C", () {
                final List<Event<int>> events = [];
                final Signal<int> a = Signal(1);
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.switchMap((a) => b.wave).subscribeEvent(events.add);
                b.close();
                a.close();
                expect(events, [
                    const NextEvent(2),
                    const CloseEvent<int>(),
                ]);
                expect(a.hasSubscribers, false);
                expect(b.hasSubscribers, false);
            });

            test("a:NC b:C", () {
                final List<Event<int>> events = [];
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.switchMap((a) => b.wave).subscribeEvent(events.add);
                b.close();
                expect(events, [
                    const NextEvent(2),
                ]);
            });

            test("a:NC b:NC", () {
                final List<Event<int>> events = [];
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(2);
                final Disposable _ = a.wave.switchMap((a) => b.wave).subscribeEvent(events.add);
                expect(events, [
                    const NextEvent(2),
                ]);
            });
            test("closing sub", () {
                final List<Event<int>> events = [];
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(2);
                final Disposable sub = a.wave.switchMap((a) => b.wave).subscribeEvent(events.add);
                sub.cancel();
                expect(events, [
                    const NextEvent(2),
                    const CloseEvent<int>(),
                ]);
            });
            test("switchMap behavior like rxjs", () {
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(10);
                // ignore: close_sinks
                final Signal<int> c = Signal(100);

                final Wave<int> awave = a.wave;
                final Wave<int> bwave = b.wave;
                final Wave<int> cwave = c.wave;

                final Wave<int> flatmapped = awave.switchMap<int>((i) => (i == 1) ? bwave : cwave);

                final List<Event<int>> events = [];

                awave.subscribeSink(EventSink((a) => events.add(KeyedEvent("a", a))));
                bwave.subscribeSink(EventSink((a) => events.add(KeyedEvent("b", a))));
                cwave.subscribeSink(EventSink((a) => events.add(KeyedEvent("c", a))));
                flatmapped.subscribeSink(EventSink((a) => events.add(KeyedEvent("fm", a))));

                b <= 20;
                a <= 2;
                c <= 200;
                b <= 30;

                c.close();
                a.close();
                b.close();

                expect(events, <dynamic>[
                    // init
                    const KeyedEvent("a", NextEvent(1)),
                    const KeyedEvent("b", NextEvent(10)),
                    const KeyedEvent("c", NextEvent(100)),
                    const KeyedEvent("fm", NextEvent(10)),
                    // test b
                    const KeyedEvent("b", NextEvent(20)),
                    const KeyedEvent("fm", NextEvent(20)),
                    // switch to c
                    const KeyedEvent("a", NextEvent(2)),
                    const KeyedEvent("fm", NextEvent(100)),
                    // test c
                    const KeyedEvent("c", NextEvent(200)),
                    const KeyedEvent("fm", NextEvent(200)),
                    // switchMap behavior: switchmap isn't subscribed to b anymore
                    const KeyedEvent("b", NextEvent(30)),
//                    const KeyedEvent("fm", NextEvent(30)),
                    // closing
                    const KeyedEvent("c", CloseEvent<int>()),
                    const KeyedEvent("a", CloseEvent<int>()),
                    const KeyedEvent("fm", CloseEvent<int>()),
                    const KeyedEvent("b", CloseEvent<int>()),
                ]);

                expect(a.hasSubscribers, false);
                expect(b.hasSubscribers, false);
            });
            test("closes", () {
                final a = Signal(1);
                final a1 = Signal(2);
                final a2 = Signal(3);

                final sut = a.wave.switchMap((int val) => val == 1 ? a1.wave : a2.wave);
                expect(sut.asStream(), emitsInOrder(<dynamic>[2, emitsDone]));

                a1.close();
                a2.close();
                a.close();
            });
            test(
                'should not close when the switching stream and the previously mapped stream close',
                    () async {
                    final a = Signal(1);
                    final a1 = Signal(2);
                    // ignore: close_sinks
                    final a2 = Signal(3);

                    final sut = a.wave.switchMap((val) => val == 1 ? a1.wave : a2.wave);

                    final _ = sut.subscribe();

                    expect(sut.asStream(), emitsInOrder(<dynamic>[2, 3, 10, emitsDone]));

                    a1.close();
                    a.add(2);
                    a.close();
                    a2.add(10);
                    a2.close();
                });
            test("cancelled switchMap doesn't receive any new events", () {
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(10);
                // ignore: close_sinks
                final Signal<int> c = Signal(100);

                final Wave<int> awave = a.wave;
                final Wave<int> bwave = b.wave;
                final Wave<int> cwave = c.wave;

                final Wave<int> switchmapped = awave.switchMap<int>((i) => (i == 1) ? bwave : cwave);

                final List<Event<int>> events = [];

                switchmapped.subscribeSink(EventSink((a) => events.add(KeyedEvent("fm", a)))).cancel();

                b <= 20;
                a <= 2;
                c <= 200;
                b <= 30;

                expect(events, <dynamic>[
                    const KeyedEvent("fm", NextEvent(10)),
                    const KeyedEvent("fm", CloseEvent<int>()),
                ]);
            });
            test("cancelling a switchmap does remove all subscribers from the source waves", () {
                // ignore: close_sinks
                final Signal<int> a = Signal(1);
                // ignore: close_sinks
                final Signal<int> b = Signal(10);

                final List<Event<int>> events = [];

                final c = a.wave.switchMap((_) => b.wave);

                final sub = c.subscribeEvent(events.add);

                expect(a.countSubscribers, 1);
                expect(b.countSubscribers, 1);
                sub.cancel();
                expect(a.countSubscribers, 0);
                expect(b.countSubscribers, 0);
            });
        });
        test("where", () {
            expect(Wave.fromIterable([1, 2, 3]).where((a) => a != 2).asStream(),
                emitsInOrder(<dynamic>[
                    1, 3, emitsDone,
                ]));
        });
        test("distinct", () {
            expect(Wave.fromIterable(["a", "b", "b", "c", "c", "c", "d"]).distinct().asStream(), emitsInOrder(<dynamic>[
                "a", "b", "c", "d", emitsDone,
            ]));
            expect(Wave.fromIterable(["a", "a"]).distinct().asStream(), emitsInOrder(<dynamic>[
                "a", emitsDone,
            ]));
            final sig = Signal(1);
            expect(sig.wave.distinct().asStream(), emitsInOrder(<dynamic>[
                1, 2, 3, emitsDone,
            ]));
            sig <= 2;
            sig <= 2;
            sig <= 3;
            sig <= 3;
            sig.close();
        });
        test("equals", () {
            final wave = Wave.fromIterable(["a", "b", "b", "c"]);

            expect(wave.equals("b").asStream(), emitsInOrder(<dynamic>[
                false, true, true, false, emitsDone,
            ]));
        });
    });
}