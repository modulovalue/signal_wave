import 'package:signal_wave/signal_wave.dart';

class StringWave extends Wave<String> {
    static StringWave from(WaveType<String> o) {
        return StringWave(o.value, o.subscribeSink);
    }

    static StringWave make<T>(Wave<T> o) {
        final oo = o.map((a) => a.toString());
        return StringWave(oo.value, oo.subscribeSink);
    }

    static StringWave just(String s) {
        return Wave.just(s).as(StringWave.from);
    }

    static StringWave join(Iterable<Wave<String>> list) {
        return Wave.combineLatest(list, (a) => a.join()).as(from);
    }

    StringWave(String value, Disposable Function(EventSink<String>) _subscribeHandler)
        : super.custom(value, _subscribeHandler);

    IntWave length() {
        return map((a) => a.length).as(IntWave.from);
    }

    BoolWave startsWith(Pattern pattern) {
        return map((a) => a.startsWith(pattern)).as(BoolWave.from);
    }

    BoolWave isNotNullNotEmpty() {
        return map((a) => a != null && a.isNotEmpty).as(BoolWave.from);
    }
}