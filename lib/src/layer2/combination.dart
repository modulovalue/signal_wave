import 'package:signal_wave/signal_wave.dart';

Wave<T> combineLatestWave<S, T>(Iterable<WaveType<S>> list, T Function(Iterable<S>) map) {
    return Wave<T>.custom(map(list.map((a) => a.value)), (EventSink<T> sink) {
        if (list.isEmpty)
            return just(map(<S>[])).subscribeSink(sink);
        final values = List.filled(list.length, MapEntry<bool, S>(false, null));
        int closed = 0,
            index = -1;
        return CompositeDisposable(list.map((WaveType<S> wave) {
            index++;
            final currentIndex = index;
            return wave.subscribe((value) {
                values[currentIndex] = MapEntry(true, value);
                if (values
                    .where((a) => a.key)
                    .length == values.length)
                    sink.add(map(list.map<S>((a) => a.value)));
            }, () {
                closed++;
                if (closed == list.length)
                    sink.close();
            });
        }).toList());
    });
}
