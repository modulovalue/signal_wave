import 'package:dartz/dartz.dart';
import 'package:signal_wave/signal_wave.dart';
import 'package:signal_wave/src/layer1/combine.dart';
import 'package:signal_wave/src/test/wave_test.dart';
import 'package:test/test.dart';

void main() {
  group("combineLatestWave", () {
    test("emits", () {
      final a = Wave.fromIterable([1]);
      final tester = WaveTester<dynamic>(
          combineLatestWave<dynamic, dynamic>([a], (a) => a.elementAt(0)));
      tester.expectCancelDidEmitTAndEnd(<dynamic>[1]);
    });
    test("should close when source waves finish", () {
      final a = Wave.fromIterable([1]);
      final b = Wave.fromIterable([10, 20]);
      final c = Wave.fromIterable([100, 200, 300]);

      final combine = combineLatestWave(
          [a, b, c], (Iterable<int> a) => a.reduce((a, b) => a + b));

      final List<Tuple2<String, Event<int>>> events = [];

      a.subscribeSink(EventSink((a) => events.add(Tuple2("a", a))));
      b.subscribeSink(EventSink((a) => events.add(Tuple2("b", a))));
      c.subscribeSink(EventSink((a) => events.add(Tuple2("c", a))));
      combine.subscribeSink(EventSink((a) => events.add(Tuple2("com", a))));

      expect(events, <Tuple2<String, Event<int>>>[
        Tuple2("a", const NextEvent(1)),
        Tuple2("a", const CloseEvent()),
        Tuple2("b", const NextEvent(10)),
        Tuple2("b", const NextEvent(20)),
        Tuple2("b", const CloseEvent()),
        Tuple2("c", const NextEvent(100)),
        Tuple2("c", const NextEvent(200)),
        Tuple2("c", const NextEvent(300)),
        Tuple2("c", const CloseEvent<int>()),
        Tuple2("com", const NextEvent(121)),
        Tuple2("com", const NextEvent(221)),
        Tuple2("com", const NextEvent(321)),
        Tuple2("com", const CloseEvent<int>()),
      ]);
    });
    test("should close when source signals close", () {
      final a = Signal(1);
      final b = Signal(10);
      final c = Signal(100);

      final combine = combineLatestWave([a.wave, b.wave, c.wave],
          (Iterable<int> a) => a.reduce((a, b) => a + b));

      final List<Tuple2<String, Event<int>>> events = [];

      a.wave.subscribeSink(EventSink((a) => events.add(Tuple2("a", a))));
      b.wave.subscribeSink(EventSink((a) => events.add(Tuple2("b", a))));
      c.wave.subscribeSink(EventSink((a) => events.add(Tuple2("c", a))));
      combine.subscribeSink(EventSink((a) => events.add(Tuple2("com", a))));

      a.add(4);
      c.add(200);
      b.add(20);
      b.add(30);

      b.close();
      c.close();
      a.close();

      expect(events, <Tuple2<String, Event<int>>>[
        Tuple2("a", const NextEvent(1)),
        Tuple2("b", const NextEvent(10)),
        Tuple2("c", const NextEvent(100)),
        Tuple2("com", const NextEvent(111)),
        Tuple2("a", const NextEvent(4)),
        Tuple2("com", const NextEvent(114)),
        Tuple2("c", const NextEvent(200)),
        Tuple2("com", const NextEvent(214)),
        Tuple2("b", const NextEvent(20)),
        Tuple2("com", const NextEvent(224)),
        Tuple2("b", const NextEvent(30)),
        Tuple2("com", const NextEvent(234)),
        Tuple2("b", const CloseEvent<int>()),
        Tuple2("c", const CloseEvent<int>()),
        Tuple2("a", const CloseEvent<int>()),
        Tuple2("com", const CloseEvent<int>()),
      ]);
    });
    test("closes all subscriptions when last subscriber cancels subscription",
        () {
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

      final latestWave = Wave.combineLatest4(a.wave, b.wave, c.wave, d.wave,
          (int a, int b, int c, int d) => a + b + c + d);
      final combine1 =
          _catchDisposalWave(latestWave, () => disposedLatestSub1++);
      final combine2 =
          _catchDisposalWave(latestWave, () => disposedLatestSub2++);

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
