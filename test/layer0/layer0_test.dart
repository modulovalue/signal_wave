import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';

void main() {
    group("disposable.dart", () {
        group("$Disposable", () {
            test("default", () {
                bool called = false;
                final d = Disposable(() => called = true);
                expect(called, false);
                expect(d.isDisposed, false);
                d.cancel();
                expect(called, true);
                expect(d.isDisposed, true);
            });
        });
        group("$CompositeDisposable", () {
            test("multiple disposables are disposed", () {
                final List<int> disposed = [];

                final CompositeDisposable disposable = CompositeDisposable([]);
                disposable.add(Disposable(() => disposed.add(1)));
                disposable.add(Disposable(() => disposed.add(2)));
                disposable.cancel();

                expect(disposed, [1, 2]);
            });

            test("called cancel multiple times does nothing", () {
                int called = 0;
                final CompositeDisposable disposable = CompositeDisposable([]);
                disposable.add(Disposable(() => called++));
                disposable.cancel();
                expect(called, 1);
                disposable.cancel();
                expect(called, 1);
            });
            test("passed disposables to a closed disposable are closed immediately",
                    () {
                    final CompositeDisposable disposable = CompositeDisposable([]);
                    disposable.cancel();
                    int called = 0;
                    disposable.add(Disposable(() => called++));
                    expect(called, 1);
                });
        });
    });

    group("events.dart", () {
        group("$Event", () {
            test("visit", () {
                /// Tested in subclasses
            });
        });
        group("$NextEvent", () {
            test("visit", () {
                int value = 0;
                const NextEvent<int>(10)
                    .visit((a) => value = a, () => throw Exception(""));
                expect(value, 10);
            });
            test("== and hashCode", () {
                // ignore: prefer_const_constructors
                expect(NextEvent<int>(10), const NextEvent<int>(10));
                expect(const NextEvent<int>(11), isNot(const NextEvent<int>(10)));
                expect(const NextEvent<int>(10).hashCode,
                    const NextEvent<int>(10).hashCode);
            });
        });
        group("$CloseEvent", () {
            test("visit", () {
                int value = 0;
                const CloseEvent<int>()
                    .visit((a) => throw Exception(""), () => value = 10);
                expect(value, 10);
            });
            test("== and hashCode", () {
                // ignore: prefer_const_constructors
                expect(CloseEvent<int>(), const CloseEvent<int>());
                expect(
                    const CloseEvent<int>().hashCode, const CloseEvent<int>().hashCode);
            });
        });
        group("$KeyedEvent", () {
            group("visits the passed event", () {
                test("CloseEvent", () {
                    final List<int> list = [];
                    const KeyedEvent("a", CloseEvent<int>()).visit((_) => fail, () => list.add(1));
                    expect(list, [1]);
                });
                test("NextEvent", () {
                    final List<int> list = [];
                    const KeyedEvent("a", NextEvent<int>(3)).visit(list.add, () => fail);
                    expect(list, [3]);
                });
            });
            test("== & != & hashCode", () {
                expect(
                    // ignore: prefer_const_constructors
                    KeyedEvent("a", CloseEvent<int>()),
                    // ignore: prefer_const_constructors
                    KeyedEvent("a", CloseEvent<int>()),
                );
                expect(
                    // ignore: prefer_const_constructors
                    KeyedEvent("a", CloseEvent<int>()).hashCode,
                    // ignore: prefer_const_constructors
                    KeyedEvent("a", CloseEvent<int>()).hashCode,
                );
                expect(
                    // ignore: prefer_const_constructors
                    KeyedEvent("a", CloseEvent<int>()),
                    // ignore: prefer_const_constructors
                    isNot(KeyedEvent("b", CloseEvent<int>())),
                );
                expect(
                    // ignore: prefer_const_constructors
                    KeyedEvent("a", CloseEvent<int>()),
                    // ignore: prefer_const_constructors
                    isNot(KeyedEvent("a", NextEvent<int>(2))),
                );
            });
        });
    });

    group("types.dart", () {
        group("$SignalValue", () {
            /// Nothing to test
        });
        group("$WaveType", () {

        });
        group("$EventSink", () {
            /// Nothing to test
        });
        group("$AnonEventSink", () {
            test("on", () {
                Event<int> event;
                const Event<int> a = NextEvent(1);
                const Event<int> b = CloseEvent();
                AnonEventSink<int>((e) => event = e).on(a);
                expect(event, a);
                AnonEventSink<int>((e) => event = e).on(b);
                expect(event, b);
            });
            test("add & close", () {
                Event<int> event;
                const Event<int> a = NextEvent(1);
                AnonEventSink<int>((e) => event = e).add(1);
                expect(event, a);
                AnonEventSink<int>((e) => event = e).close();
                expect(event, const CloseEvent<int>());
            });
        });
    });
}