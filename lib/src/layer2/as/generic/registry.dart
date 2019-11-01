import 'package:signal_wave/signal_wave.dart';

class RegistryWave<T> extends Wave<Map<String, List<T>>> {
    static RegistryWave<T> from<T>(WaveType<Map<String, List<T>>> o) {
        return RegistryWave(o);
    }

    RegistryWave(WaveType<Map<String, List<T>>> wave)
        : super.custom(wave.value, wave.subscribeSink);

    IntWave countAll() {
        return map<int>((a) {
            return a.entries.map((f) {
                return f.value.length;
            }).fold(0, (a, b) => a + b);
        }).as(IntWave.from);
    }

    ListWave<T> at(String domain) => map((a) => a[domain] ?? []).as(ListWave.from);
}