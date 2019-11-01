import 'package:signal_wave/signal_wave.dart';

class IntWave extends Wave<int> {
  static IntWave from(WaveType<int> o) {
    return IntWave(o.value, o.subscribeSink);
  }

  IntWave(int value, Disposable Function(EventSink<int>) _subscribeHandler)
      : super.custom(value, _subscribeHandler);

  BoolWave operator >(int i) => map((a) => a > i).as(BoolWave.from);

  BoolWave operator <(int i) => map((a) => a < i).as(BoolWave.from);

  BoolWave operator >=(int i) => map((a) => a >= i).as(BoolWave.from);

  BoolWave operator <=(int i) => map((a) => a <= i).as(BoolWave.from);

  IntWave operator +(int i) => map((a) => a + i).as(IntWave.from);

  @override
  BoolWave equals(int i) => map((a) => a == i).as(BoolWave.from);

  IntWave multiply(int i) => map((a) => a * i).as(IntWave.from);
}
