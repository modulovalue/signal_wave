abstract class Event<T> {
  const Event._();

  void visit(void Function(T) onValue, void Function() onCompleted);
}

class NextEvent<T> extends Event<T> {
  final T value;

  const NextEvent(this.value) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NextEvent &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  void visit(void Function(T) onValue, void Function() onCompleted) =>
      onValue(value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$runtimeType{value: $value}';
}

class CloseEvent<T> extends Event<T> {
  const CloseEvent() : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloseEvent && runtimeType == other.runtimeType;

  @override
  void visit(void Function(T) onValue, void Function() onCompleted) =>
      onCompleted();

  @override
  int get hashCode => 0;

  @override
  String toString() => '$runtimeType{}';
}

/// Decorates an event with a key so it can be associated with a specific wave.
class KeyedEvent<T> extends Event<T> {
  final Event<T> event;

  final Object key;

  const KeyedEvent(this.key, this.event) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyedEvent &&
          runtimeType == other.runtimeType &&
          event == other.event &&
          key == other.key;

  @override
  void visit(void Function(T) onValue, void Function() onCompleted) =>
      event.visit(onValue, onCompleted);

  @override
  int get hashCode => event.hashCode ^ key.hashCode;

  @override
  String toString() => '$runtimeType{event: $event, key: $key}';
}
