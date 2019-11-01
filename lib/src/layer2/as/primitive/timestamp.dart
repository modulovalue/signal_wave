import 'package:signal_wave/signal_wave.dart';
import 'package:dartz/dartz.dart';

class TimestampWave extends Wave<int> {
    static TimestampWave from(WaveType<int> o) {
      return TimestampWave(o.value, o.subscribeSink);
    }

    TimestampWave(int value, Disposable Function(EventSink<int>) _subscribeHandler)
        : super.custom(value, _subscribeHandler);

    BoolWave isPresent() => map((a) => a != null && a > 0).as(BoolWave.from);

    Wave<Option<DateTime>> date() => map((a) => a != null && a > 0 ? Some(DateTime.fromMillisecondsSinceEpoch(a)) : const None());
}
