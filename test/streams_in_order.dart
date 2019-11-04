import 'dart:async';

import 'package:test/test.dart';

/// Lets you test whether streams emit their values and events in an
/// order relative to each other.
///
/// If you don't need typed keys then use [expectStreamsInOrderInline]
void expectStreamsInOrder(Iterable<StreamKey> keys, dynamic matcher,
    {Function(StreamEventType) onEach}) {
  final Map<dynamic, StreamSubscription> subs = <dynamic, StreamSubscription>{};

  assert(keys.map<dynamic>((a) => a.key).toSet().length == keys.length,
      "All keys need to be unique");

  final StreamController<StreamEventType> s =
      StreamController.broadcast(sync: true);

  StreamSubscription<StreamEventType> doOnEachSub;

  if (onEach != null) {
    doOnEachSub = s.stream.listen(onEach);
  }

  expect(s.stream, matcher);

  void isLastSubscriptionCancelled() {
    assert(!s.isClosed);
    if (subs.values.isEmpty) {
      doOnEachSub?.cancel();
      s.close();
    }
  }

  for (final key in keys) {
    subs[key.key] = key.stream.listen(
      (dynamic data) {
        s.add(key.emits(data));
      },
      onError: (dynamic error) {
        s.add(key.error(error));
        subs.remove(key.key).cancel();
        isLastSubscriptionCancelled();
      },
      onDone: () {
        s.add(key.done());
        subs.remove(key.key).cancel();
        isLastSubscriptionCancelled();
      },
    );
  }
}

/// Inspired by TypedRegistry at
/// https://github.com/google/charts/blob/35aeffe7c96aa7d231c90fddd9766998545f1080/charts_common/lib/src/common/typed_registry.dart
class StreamKey<T extends Object> {
  final Object key;

  final Stream<T> stream;

  const StreamKey(this.key, this.stream);

  const StreamKey.one(this.stream) : this.key = stream;

  StreamEventType emits(T t) => StreamEmitted(key, t);

  StreamEventType done() => StreamDone(key);

  StreamEventType error(dynamic error) => StreamErrored(key, error);
}

void expectStreamsInOrderInline(List<Stream> streams,
    dynamic Function(StreamKey Function(dynamic) k) matcher) {
  final goodKeys = streams.map((a) => StreamKey<dynamic>(a, a));
  expectStreamsInOrder(goodKeys, matcher((dynamic key) {
    return goodKeys.firstWhere(
      (a) => a.key == key,
      orElse: () => throw Exception("Key not found"),
    );
  }));
}

abstract class StreamEventType {
  final dynamic key;

  const StreamEventType(this.key);
}

class StreamEmitted<T> extends StreamEventType {
  final T data;

  const StreamEmitted(dynamic key, this.data) : super(key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamEmitted &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          data == other.data;

  @override
  int get hashCode => data.hashCode ^ key.hashCode;

  @override
  String toString() => 'StreamEmitted{key: $key, data: $data}';
}

class StreamDone extends StreamEventType {
  const StreamDone(dynamic key) : super(key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamDone &&
          key == other.key &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'StreamDone{key: $key}';
}

class StreamErrored extends StreamEventType {
  final dynamic error;

  const StreamErrored(dynamic key, this.error) : super(key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamErrored &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          error == other.error;

  @override
  int get hashCode => error.hashCode ^ key.hashCode;

  @override
  String toString() => 'StreamErrored{key: $key, error: $error}';
}

FutureOr<T> subscribeDuring<T>(
    StreamSubscription<T> sub, FutureOr<T> Function() execute) async {
  final a = await execute();
  await sub.cancel();
  return a;
}

StreamSubscriptionDecorator<T> expectSub<T>(
        Stream<T> stream, dynamic matcher) =>
    SurrogateStream<T>(matcher).listen(stream);

/// Allows one to 'expect' on stream subscriptions.
///
/// Stream matchers will match an "emitsDone" when the subscription provided by [listen] is cancelled.
///
/// Useful when you'd like to define the test logic before listening to a
/// stream (because listening to it may do something like for example reacting to the first listener in the onListen method).
class SurrogateStream<T> {
  StreamController<T> stream = StreamController(sync: true);

  bool _initialized = false;

  final dynamic matcher;

  SurrogateStream(this.matcher);

  StreamSubscriptionDecorator<T> listen(Stream<T> s) {
    assert(!_initialized, "You can only listen once on SurrogateStreams");
    _initialized = true;
    expect(stream.stream, matcher);
    return StreamSubscriptionDecorator(
      s.listen(
        stream.add,
        onError: stream.addError,
        onDone: () => stream.close(),
        cancelOnError: true,
      ),
      onCancel: stream.close,
    );
  }
}

class StreamSubscriptionDecorator<T> implements StreamSubscription<T> {
  final StreamSubscription<T> sub;

  final void Function() onCancel;

  const StreamSubscriptionDecorator(this.sub, {this.onCancel});

  @override
  Future<E> asFuture<E>([E futureValue]) => sub.asFuture(futureValue);

  @override
  Future<void> cancel() async {
    onCancel?.call();
    return sub.cancel();
  }

  @override
  bool get isPaused => sub.isPaused;

  @override
  void onData(void Function(T data) handleData) => sub.onData(handleData);

  @override
  void onDone(void Function() handleDone) => sub.onDone(handleDone);

  @override
  void onError(Function handleError) => sub.onError(handleError);

  @override
  void pause([Future resumeSignal]) => sub.pause(resumeSignal);

  @override
  void resume() => sub.resume();

  FutureOr<void> doThenCancel(FutureOr<void> Function() execute) async {
    await execute();
    await cancel();
  }
}
