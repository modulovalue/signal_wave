import 'dart:convert';

import 'package:signal_wave/signal_wave.dart';

class CodecWave<S, T> extends Wave<S> {
    final Converter<S, T> converter;

    CodecWave(S value, this.converter,
        Disposable Function(EventSink<S>) _subscribeHandler)
        : super.custom(value, _subscribeHandler);

    WaveType<T> convert() => super.map(converter.convert);
}
