import 'disposable.dart';
import 'events.dart';

abstract class SignalValue<S> {
    S get value;
}

abstract class WaveType<S> implements SignalValue<S> {

    Disposable subscribeSink(EventSink<S> observer);

    Disposable subscribeEvent(void Function(Event<S>) events) {
        return subscribeSink(EventSink(events));
    }

    Disposable subscribe([void Function(S) onNext, void Function() onCancel]) {
        return subscribeEvent((event) {
            event.visit((a) {
                onNext?.call(a);
            }, () {
                onCancel?.call();
            });
        });
    }

    void onAdd(S s) {}
}

abstract class SignalType<S> extends SignalValue<S> implements EventSink<S> {

    WaveType<S> get wave;

    @override
    void add(S data) => on(NextEvent<S>(data));

    @override
    void close() => on(CloseEvent<S>());

    EventSink<T> sinkMap<T>(S Function(T) map) => _MappedSink(this, map);
}

abstract class EventSink<S> implements Sink<S> {

    factory EventSink(void Function(Event<S> handle) handler) = AnonEventSink<S>;

    void on(Event<S> event);

    const EventSink.sub();
}

class AnonEventSink<S> implements EventSink<S> {

    final void Function(Event<S> handle) _handler;

    const AnonEventSink(this._handler);

    @override
    void add(S data) => on(NextEvent<S>(data));

    @override
    void close() => on(CloseEvent<S>());

    @override
    void on(Event<S> event) => _handler(event);
}

class _MappedSink<F, S> implements EventSink<F> {

    final EventSink<S> _source;

    final S Function(F) map;

    const _MappedSink(this._source, this.map);

    @override
    void add(F data) => on(NextEvent<F>(data));

    @override
    void close() => on(CloseEvent<F>());

    @override
    void on(Event<F> event) => event.visit((a) => _source.add(map(a)), _source.close);
}