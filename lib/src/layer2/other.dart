import 'dart:async' hide EventSink;
import 'dart:async';

import 'package:signal_wave/signal_wave.dart';

mixin WaveOtherMixin<S> on WaveType<S> {
    Future<List<Event<S>>> asFuture() {
        final List<Event<S>> events = [];

        final completer = Completer<List<Event<S>>>();

        subscribe((value) {
            events.add(NextEvent<S>(value));
        }, () {
            events.add(CloseEvent<S>());
            completer.complete(events);
        });
        return completer.future;
    }

    Future<Event<S>> oneAsFuture() {
        final completer = Completer<Event<S>>();

        final disposable = Wave(this).take(1).subscribe((value) {
            completer.complete(NextEvent<S>(value));
        }, () {
            if (!completer.isCompleted)
                completer.complete(CloseEvent<S>());
        });

        return completer.future.then((result) {
            disposable.cancel();
            return result;
        }, onError: (dynamic _) {
            disposable.cancel();
            return CloseEvent<S>();
        });
    }

    Future<Event<S>> nextAsFuture() {
        return Wave(this).skip(1).oneAsFuture();
    }

    Stream<S> asStream({void Function() onListen, void Function() onCancel}) {
        StreamController<S> controller;
        Disposable d;
        controller = StreamController(
            onListen: () {
                d = subscribe((a) {
                    controller.add(a);
                }, controller.close);
                onListen?.call();
            },
            onCancel: () {
                d.cancel();
                onCancel?.call();
            });
        return controller.stream;
    }

    Stream<S> asBroadcastStream({void Function() onListen, void Function() onCancel}) {
        return asStream().asBroadcastStream(
            onListen: (_) => onListen?.call(), onCancel: (_) => onCancel?.call());
    }
}
