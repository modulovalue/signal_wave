import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';

class WaveTester<T> {
  final Wave<T> wave;

  List<Event<T>> events;

  Disposable subscription;

  WaveTester(this.wave) {
    events = [];
    subscription = wave.subscribeEvent(events.add);
  }

  void expectCancelDidEmit(List<Event<T>> events) {
    subscription.cancel();
    expect(this.events, events);
    this.events = [];
  }

  void expectDidEmit(List<Event<T>> events) {
    expect(this.events, events);
    this.events = [];
  }

  void expectCancelDidEmitTAndEnd(List<T> values) {
    expectCancelDidEmit(
        [...values.map((a) => NextEvent<T>(a)), CloseEvent<T>()]);
  }

  void expectCancelDidEmitT(List<T> values) {
    expectCancelDidEmit([...values.map((a) => NextEvent<T>(a))]);
  }

  void exepctDidEmitTAndEnd(List<T> values) {
    expectDidEmit([...values.map((a) => NextEvent<T>(a)), CloseEvent<T>()]);
  }

  void expectDidEmitT(List<T> values) {
    expectDidEmit([...values.map((a) => NextEvent<T>(a))]);
  }
}
