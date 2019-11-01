import 'package:signal_wave/signal_wave.dart';

class DynWave {

    /// Make sure that [T] overrides the + operator
    static Wave<T> sum<T extends dynamic>(Iterable<Wave<T>> list) {
        return Wave.combineLatestID<T>(list).map((a) => a.reduce((a, b) => a + b as T));
    }

    /// Make sure that [T] overrides the == operator
    static Wave<bool> equals2<T extends dynamic>(Wave<T> a, Wave<T> b) {
        return a.and(b).latest((T a, T b) => a == b);
    }
}