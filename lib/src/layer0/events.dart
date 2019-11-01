abstract class Event<T> {

    const Event();

    void visit(void Function(T) onValue, void Function() onCompleted) {
        final self = this;
        if (self is NextEvent<T>)
            onValue(self.value);
        if (self is CloseEvent)
            onCompleted();
    }
}

class NextEvent<T> extends Event<T> {

    final T value;

    const NextEvent(this.value);

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is NextEvent &&
                runtimeType == other.runtimeType &&
                value == other.value;

    @override
    int get hashCode => value.hashCode;

    @override
    String toString() => 'NextEvent{value: $value}';
}

class CloseEvent<T> extends Event<T> {

    const CloseEvent();

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is CloseEvent && runtimeType == other.runtimeType;

    @override
    int get hashCode => 0;

    @override
    String toString() => 'CompletedEvent{}';
}

/// Decorates an event with a key so it can be associated with a specific wave.
class KeyedEvent<T> extends Event<T> {

    final Event<T> event;

    final Object key;

    const KeyedEvent(this.key, this.event);

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is KeyedEvent &&
                runtimeType == other.runtimeType &&
                event == other.event &&
                key == other.key;

    @override
    void visit(void Function(T) onValue, void Function() onCompleted) {
        event.visit(onValue, onCompleted);
    }

    @override
    int get hashCode => event.hashCode ^ key.hashCode;

    @override
    String toString() => '$runtimeType{event: $event, key: $key}';
}