import 'package:signal_wave/signal_wave.dart';
import 'package:signal_wave/src/layer2/combination.dart';
import 'package:signal_wave/src/tester/wave_tester.dart';
import 'package:test/test.dart';

void main() {
    group("combineLatestWave", () {
        test("emits", () {
            final a = Wave.fromIterable([1]);
            final tester = WaveTester<dynamic>(combineLatestWave<dynamic, dynamic>([a], (a) => a.elementAt(0)));
            tester.expectCancelDidEmitTAndEnd(<dynamic>[1]);
        });
        test("should close when source waves finish", () {
            final a = Wave.fromIterable([1]);
            final b = Wave.fromIterable([10, 20]);
            final c = Wave.fromIterable([100, 200, 300]);

            final combine = combineLatestWave([a, b, c], (Iterable<int> a) => a.reduce((a, b) => a + b));

            final List<_Tuple<String, Event<int>>> events = [];

            a.subscribeSink(EventSink((a) => events.add(_Tuple("a", a))));
            b.subscribeSink(EventSink((a) => events.add(_Tuple("b", a))));
            c.subscribeSink(EventSink((a) => events.add(_Tuple("c", a))));
            combine.subscribeSink(EventSink((a) => events.add(_Tuple("com", a))));

            expect(events, <_Tuple<String, Event<int>>>[
                const _Tuple("a", NextEvent(1)),
                const _Tuple("a", CloseEvent()),
                const _Tuple("b", NextEvent(10)),
                const _Tuple("b", NextEvent(20)),
                const _Tuple("b", CloseEvent()),
                const _Tuple("c", NextEvent(100)),
                const _Tuple("c", NextEvent(200)),
                const _Tuple("c", NextEvent(300)),
                const _Tuple("c", CloseEvent<int>()),
                const _Tuple("com", NextEvent(121)),
                const _Tuple("com", NextEvent(221)),
                const _Tuple("com", NextEvent(321)),
                const _Tuple("com", CloseEvent<int>()),
            ]);
        });
        test("should close when source signals close", () {
            final a = Signal(1);
            final b = Signal(10);
            final c = Signal(100);

            final combine = combineLatestWave([a.wave, b.wave, c.wave], (Iterable<int> a) => a.reduce((a, b) => a + b));

            final List<_Tuple<String, Event<int>>> events = [];

            a.wave.subscribeSink(EventSink((a) => events.add(_Tuple("a", a))));
            b.wave.subscribeSink(EventSink((a) => events.add(_Tuple("b", a))));
            c.wave.subscribeSink(EventSink((a) => events.add(_Tuple("c", a))));
            combine.subscribeSink(EventSink((a) => events.add(_Tuple("com", a))));

            a.add(4);
            c.add(200);
            b.add(20);
            b.add(30);

            b.close();
            c.close();
            a.close();

            expect(events, <_Tuple<String, Event<int>>>[
                const _Tuple("a", NextEvent(1)),
                const _Tuple("b", NextEvent(10)),
                const _Tuple("c", NextEvent(100)),
                const _Tuple("com", NextEvent(111)),
                const _Tuple("a", NextEvent(4)),
                const _Tuple("com", NextEvent(114)),
                const _Tuple("c", NextEvent(200)),
                const _Tuple("com", NextEvent(214)),
                const _Tuple("b", NextEvent(20)),
                const _Tuple("com", NextEvent(224)),
                const _Tuple("b", NextEvent(30)),
                const _Tuple("com", NextEvent(234)),
                const _Tuple("b", CloseEvent<int>()),
                const _Tuple("c", CloseEvent<int>()),
                const _Tuple("a", CloseEvent<int>()),
                const _Tuple("com", CloseEvent<int>()),
            ]);
        });
        test("closes all subscriptions when last subscriber cancels subscription", () {
            // ignore: close_sinks
            final a = Signal(1);
            // ignore: close_sinks
            final b = Signal(10);
            // ignore: close_sinks
            final c = Signal(100);
            // ignore: close_sinks
            final d = Signal(1000);

            int disposedASub = 0;
            int disposedBSub = 0;
            int disposedCSub = 0;
            int disposedDSub = 0;
            int disposedLatestSub1 = 0;
            int disposedLatestSub2 = 0;

            final aSub = _catchDisposalWave(a.wave, () => disposedASub++).subscribe();
            final bSub = _catchDisposalWave(b.wave, () => disposedBSub++).subscribe();
            final cSub = _catchDisposalWave(c.wave, () => disposedCSub++).subscribe();
            final dSub = _catchDisposalWave(d.wave, () => disposedDSub++).subscribe();

            final latestWave = Wave.combineLatest4(a.wave, b.wave, c.wave, d.wave, (int a, int b, int c, int d) => a + b + c + d);
            final combine1 = _catchDisposalWave(latestWave, () => disposedLatestSub1++);
            final combine2 = _catchDisposalWave(latestWave, () => disposedLatestSub2++);

            final latestSub1 = combine1.subscribe();
            final latestSub2 = combine2.subscribe();

            latestSub2.cancel();
            a.add(2);
            aSub.cancel();
            b.add(20);
            bSub.cancel();
            c.add(200);
            latestSub1.cancel();
            d.add(2000);
            cSub.cancel();
            dSub.cancel();
        });
    });
}

Wave<T> _catchDisposalWave<T>(Wave<T> wave, void Function() didClose) {
    return Wave<T>.custom(wave.value, (sink) {
        return wave.subscribe((next) {
            sink.add(next);
        }, () {
            didClose();
            sink.close();
        });
    });
}

class _Tuple<A, B> {
    final A a;
    final B b;

    const _Tuple(this.a, this.b);

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is _Tuple &&
                runtimeType == other.runtimeType &&
                a == other.a &&
                b == other.b;

    @override
    int get hashCode =>
        a.hashCode ^
        b.hashCode;

    @override
    String toString() {
        return '_Tuple{a: $a, b: $b}';
    }
}