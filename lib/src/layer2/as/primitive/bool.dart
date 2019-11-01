import 'package:signal_wave/signal_wave.dart';

class BoolWave extends Wave<bool> {
    static BoolWave from(WaveType<bool> o) {
        return BoolWave(o);
    }

    BoolWave(WaveType<bool> o) : super(o);

    Wave<T> ifTrueThen<T>(T Function() t, {T Function() orElse}) => map((a) => a ? t() : orElse?.call());

    BoolWave not() => map((a) => !a).as(BoolWave.from);

    BoolWave or(BoolWave wave) => this.and(wave).latest((bool a, bool b) => a || b).as(BoolWave.from);

    BoolWave andBool(BoolWave wave) => this.and(wave).latest((bool a, bool b) => a && b).as(BoolWave.from);

    BoolWave operator |(BoolWave wave) => or(wave);

    BoolWave operator &(BoolWave wave) => andBool(wave);
}
