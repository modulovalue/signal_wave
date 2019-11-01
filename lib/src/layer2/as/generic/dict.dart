import 'package:signal_wave/signal_wave.dart';

class DictWave<T> extends Wave<Map<String, T>> {
    static DictWave<T> from<T>(WaveType<Map<String, T>> o) {
        return DictWave(o);
    }

    DictWave(WaveType<Map<String, T>> o) : super(o);

    IntWave length() => map((a) => a.length).as(IntWave.from);

    BoolWave isEmpty() => map((a) => a.isEmpty).as(BoolWave.from);
}