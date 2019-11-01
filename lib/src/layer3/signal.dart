import 'package:meta/meta.dart';
import 'package:signal_wave/signal_wave.dart';

abstract class Signal<S> extends SignalType<S> {
    factory Signal(S _value, {void Function() onListen, void Function() onCancel, void Function(Signal<S>) onInit}) {
        return _Signal<S>(_value, onListen: onListen, onCancel: onCancel, onInit: onInit);
    }

    Signal.sub();

    bool get hasSubscribers;

    @visibleForTesting
    int get countSubscribers;

    @override
    Wave<S> get wave;

    bool get isClosed;

    void operator <=(S s);
}

class _Signal<S> extends Signal<S> {

    S _value;

    @override
    S get value => _value;

    set value(S value) => add(value);

    final void Function() _onListen;

    final void Function() _onCancel;

    _Signal(this._value, {void Function() onListen, void Function() onCancel, void Function(Signal<S>) onInit})
        :
            this._onListen = onListen ?? (() {}),
            this._onCancel = onCancel ?? (() {}),
            super.sub() {
        onInit?.call(this);
    }

    @override
    int get countSubscribers => _subscribers.length;

    final Set<EventSink<S>> _subscribers = {};

    @override
    bool get hasSubscribers => _subscribers.isNotEmpty;

    Wave<S> get _wave =>
        Wave.custom(value, (sink) {
            if (_isClosed)
                return Disposable(sink.close);

            Disposable disposable;

            EventSink<S> realSink = EventSink<S>((event) {
                event.visit((_) {}, () => disposable.cancel());
                sink.on(event);
            });

            final subscribersWereEmpty = _subscribers.isEmpty;

            _subscribers.add(realSink);

            realSink.add(value);

            if (subscribersWereEmpty)
                _onListen();

            return disposable = Disposable(() {
                _subscribers.remove(realSink);
                realSink.close();
                if (_subscribers.isEmpty)
                    _onCancel();
                realSink = null;
                disposable = null;
            });
        });

    @override
    Wave<S> get wave => _wave;

    @override
    void operator <=(S s) => add(s);

    bool _isClosed = false;

    @override
    bool get isClosed => _isClosed;

    @override
    void on(Event<S> event) => event.visit(add, close);

    @override
    void add(S data) {
        if (isClosed)
            throw Exception("You can't set a new value on a closed signal.");
        _value = data;
        // to prevent Concurrent modification during iteration.
        Set<EventSink<S>>
            .from(_subscribers)
            .forEach((c) => c.add(data));
    }

    @override
    void close() {
        if (!_isClosed) {
            _isClosed = true;
            // to prevent Concurrent modification during iteration.
            Set<EventSink<S>>
                .from(_subscribers)
                .forEach((c) => c.close());
        }
    }
}
