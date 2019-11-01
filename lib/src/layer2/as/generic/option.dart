import 'package:dartz/dartz.dart';
import 'package:signal_wave/signal_wave.dart';

class OptionWave<T> extends Wave<Option<T>> {
    static OptionWave<T> from<T>(WaveType<Option<T>> o) {
        return OptionWave<T>(o);
    }

    OptionWave(WaveType<Option<T>> o) : super(o);

    static OptionWave<T> upcast2<T>(Wave<Option<T>> a, Wave<Option<T>> b) {
        return a.and(b).latest((Option<T> a, Option<T> b) {
            return a.fold(() => b.fold(() => None<T>(), some), some);
        }).as((a) => OptionWave.from<T>(a));
    }

    OptionWave<U> oMap<U>(U Function(T) m) {
        return this.map((a) => a.map(m)).as(OptionWave.from);
    }

    BoolWave isSome() => map((a) => a.isSome()).as(BoolWave.from);
}