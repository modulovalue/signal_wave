import 'package:functional_data/functional_data.dart';
import 'package:signal_wave/signal_wave.dart';

class SignalLens<T> {

    final Future<void> Function(T) set;

    final Wave<T> get;

    const SignalLens(this.set, this.get);

    SignalLens<U> map<U>(Future<void> Function(U) newSetter, U Function(T) map) {
        return SignalLens(newSetter, get.map(map));
    }

    SignalLens<O> then<O>(Lens<T, O> lens) {
        return SignalLens((O mode) => set(lens.update(get.value, mode)), get.map(lens.get));
    }
}