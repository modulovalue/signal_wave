import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:signal_wave/src/layer1/creation.dart';
import 'package:signal_wave/src/test/wave_test.dart';
import 'package:test/test.dart';

import '../streams_in_order.dart';

void main() {
  group("creational.dart", () {
    test("justWave", () {
      expect(justWave(1).asStream(), emitsInOrder(<dynamic>[1, emitsDone]));
    });
    test("emptyWave", () {
      expect(emptyWave<int>().asStream(), emitsInOrder(<dynamic>[emitsDone]));
    });
    test("fromIterableWave", () {
      expect(fromIterableWave<int>([1, 2]).asStream(),
          emitsInOrder(<dynamic>[1, 2, emitsDone]));
      expect(fromIterableWave<int>([]).asStream(),
          emitsInOrder(<dynamic>[emitsDone]));
    });
    group("fromStreamWave", () {
      test("no error", () async {
        StreamController<int> controller;
        controller = StreamController<int>();
        final test =
            WaveTester(fromStreamWave(controller.stream.asBroadcastStream()));
        controller.sink.add(5);
        await controller.close();
        await pumpEventQueue();
        test.expectCancelDidEmitTAndEnd([
          None(),
          Some(Right<dynamic, int>(5)),
        ]);
      });
      test("error", () async {
        // ignore: close_sinks
        StreamController<int> controller;
        controller = StreamController<int>();
        final test =
            WaveTester(fromStreamWave(controller.stream.asBroadcastStream()));
        controller.sink.add(5);
        controller.sink.addError("error-object");
        await pumpEventQueue();
        test.expectCancelDidEmitTAndEnd([
          None(),
          Some(Right<dynamic, int>(5)),
          Some(Left<dynamic, int>("error-object")),
        ]);
      });
    });
    test("generateWave", () {
      expect(generateWave<int>(2, (a) => a).asStream(),
          emitsInOrder(<dynamic>[0, 1, emitsDone]));
      expect(generateWave<int>(0, (a) => a).asStream(),
          emitsInOrder(<dynamic>[emitsDone]));
    });
    test("periodic", () async {
      expectSub(
          periodic(const Duration(milliseconds: 500), (a) => a).asStream(),
          emitsInOrder(<dynamic>[
            0,
            1,
            2,
            emitsDone,
          ])).doThenCancel(() async {
        await Future<void>.delayed(const Duration(milliseconds: 1250));
      });
      expectSub(
          periodic(const Duration(milliseconds: 500), (a) => a).asStream(),
          emitsInOrder(<dynamic>[
            0,
            emitsDone,
          ])).doThenCancel(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
    });
  });
  test("repeatWave", () {
    expect(
        repeatWave(0, 1).asStream(),
        emitsInOrder(<dynamic>[
          emitsDone,
        ]));
  });
}
