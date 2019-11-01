import 'dart:async';

import 'package:test/test.dart';

import 'streams_in_order.dart';

enum SomeStatus {
    loading,
    connected,
    disconnected,
}

void main() {
    group("$expectStreamsInOrder", () {
        StreamController<String> data; // ignore: close_sinks
        StreamController<SomeStatus> status; // ignore: close_sinks
        StreamKey<String> keyData;
        StreamKey<SomeStatus> keyStatus;

        setUp(() {
            data = StreamController(sync: true);
            status = StreamController(sync: true);
            keyData = StreamKey(data, data.stream);
            keyStatus = StreamKey(status, status.stream);
        });

        test("example", () {
            final Stream<SomeStatus> a = Stream.fromIterable([SomeStatus.loading, SomeStatus.connected, SomeStatus.disconnected]);
            final Stream<String> b = Stream.fromIterable(["a", "b"]);

            expectStreamsInOrderInline([a, b], (g) =>
                emitsInOrder(<dynamic>[
                    g(a).emits(SomeStatus.loading),
                    g(b).emits("a"),
                    g(a).emits(SomeStatus.connected),
                    g(b).emits("b"),
                    g(a).emits(SomeStatus.disconnected),
                    g(b).done(),
                    g(a).done(),
                    emitsDone,
                ]));
        });

        test("example with keys", () async {
            expectStreamsInOrder([keyData, keyStatus], emitsInOrder(<dynamic>[
                keyStatus.emits(SomeStatus.loading),
                keyStatus.emits(SomeStatus.connected),
                keyData.emits("a"),
                keyStatus.emits(SomeStatus.disconnected),
                keyData.done(),
                keyStatus.done(),
                emitsDone,
            ]));

            status.add(SomeStatus.loading);
            status.add(SomeStatus.connected);
            data.add("a");
            status.add(SomeStatus.disconnected);
            await data.close();
            await status.close();
        });

        test("example inline", () async {
            expectStreamsInOrderInline([data.stream, status.stream], (g) =>
                emitsInOrder(<dynamic>[
                    g(status.stream).emits(SomeStatus.loading),
                    g(status.stream).emits(SomeStatus.connected),
                    g(data.stream).emits("a"),
                    g(status.stream).emits(SomeStatus.disconnected),
                    g(data.stream).done(),
                    g(status.stream).done(),
                    emitsDone,
                ]));

            status.add(SomeStatus.loading);
            status.add(SomeStatus.connected);
            data.add("a");
            status.add(SomeStatus.disconnected);
            await data.close();
            await status.close();
        });

        test("example with error", () async {
            expectStreamsInOrder([keyData, keyStatus], emitsInOrder(<dynamic>[
                keyStatus.emits(SomeStatus.loading),
                keyStatus.emits(SomeStatus.connected),
                keyData.emits("a"),
                keyStatus.emits(SomeStatus.disconnected),
                keyData.error("err1"),
                keyStatus.error("err2"),
                emitsDone,
            ]));

            status.add(SomeStatus.loading);
            status.add(SomeStatus.connected);
            data.add("a");
            status.add(SomeStatus.disconnected);
            data.addError("err1");
            status.addError("err2");
        });

        test("-", () async {
            expectStreamsInOrder([keyData, keyStatus], emitsInOrder(<dynamic>[
                keyData.emits("aa"),
                keyStatus.emits(SomeStatus.loading),
                keyData.error(123),
                keyStatus.done(),
                emitsDone,
            ]));

            data.add("aa");
            status.add(SomeStatus.loading);
            data.addError(123);
            await status.close();
        });

        test("-", () async {
            expectStreamsInOrder([keyData, keyStatus], emitsInOrder(<dynamic>[
                keyData.emits("aa"),
                keyStatus.emits(SomeStatus.loading),
                keyStatus.done(),
                keyData.error(123),
                emitsDone,
            ]));

            data.add("aa");
            status.add(SomeStatus.loading);
            await status.close();
            data.addError(123);
        });
    });

    test("a", () async {
        Timer t;

        void createTimer(Sink<int> sink) {
            t = Timer(const Duration(milliseconds: 50), () {
                sink.add(1);
                createTimer(sink);
            });
        }

        StreamController<int> s;
        s = StreamController.broadcast(
            onListen: () => createTimer(s),
            onCancel: () => t.cancel(),
        );

        final sub = expectSub(s.stream, emitsInOrder(<dynamic>[
                (dynamic a) => a == 1,
            1,
            emitsDone,
        ]));
        await Future<void>.delayed(const Duration(milliseconds: 120));
        await sub.cancel();
    });

    test("Observable", () async {
        Timer t;

        void createTimer(Sink<int> sink) {
            t = Timer(const Duration(milliseconds: 50), () {
                sink.add(1);
                createTimer(sink);
            });
        }

        StreamController<int> s;
        s = StreamController(
            onListen: () => createTimer(s),
            onCancel: () => t.cancel(),
        );

        final sub = expectSub(s.stream, emitsInOrder(<dynamic>[
            1,
            1,
            emitsDone,
        ]));

        await Future<void>.delayed(const Duration(milliseconds: 120));

        await s.close();
        await sub.cancel();
        await Future<void>.delayed(const Duration(milliseconds: 50));
    });
}
