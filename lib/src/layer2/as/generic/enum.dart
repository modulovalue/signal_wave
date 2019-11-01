import 'package:signal_wave/signal_wave.dart';

class EnumWave<T> extends Wave<T> {
    static EnumWave<T> Function(WaveType<String> o) from<T>(List<T> all, T deflt) {
        return (o) => EnumWave(Wave(o), all, deflt);
    }
    static EnumWave<T> Function(WaveType<T> o) fromT<T>(List<T> all, T deflt) {
        return (o) => EnumWave(Wave(o).map((a) => a.toString()), all, deflt);
    }

    final List<T> _all;
    final T _deflt;

    EnumWave(Wave<String> wave, this._all, this._deflt)
        : super(wave.map(_firstOfList(_all, _deflt)));

    EnumWave<T> next() {
        return map((a) => walk(_all, a, direction: _ToggleDirection.forwards))
            .map((a) => a.toString())
            .as(EnumWave.from(_all, _deflt));
    }

    EnumWave<T> previous() {
        return map((a) => walk(_all, a, direction: _ToggleDirection.backwards))
            .map((a) => a.toString())
            .as(EnumWave.from(_all, _deflt));
    }

    IntWave index() => map<int>((T a) => (a as dynamic).index as int).as(IntWave.from);

    static T walk<T>(List<T> list, T current, {_ToggleDirection direction = _ToggleDirection.forwards}) {
        assert(direction != null);
        assert(list != null);
        assert(list.isNotEmpty);

        final int index = list.indexOf(current);

        switch (direction) {
            case _ToggleDirection.forwards:
                if (index == list.length - 1) {
                    return list.first;
                } else {
                    return list[index + 1];
                }
                break;
            case _ToggleDirection.backwards:
                if (index == 0) {
                    return list.last;
                } else {
                    return list[index - 1];
                }
                break;
        }
        return null;
    }
}

U Function(dynamic c) _firstOfList<U>(List<U> list, U init) =>
        (dynamic c) => list.firstWhere((a) => a.toString() == c.toString(), orElse: () => init);

enum _ToggleDirection {
    /// To the left
    forwards,

    /// To the right
    backwards,
}
