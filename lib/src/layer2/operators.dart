import 'package:async/async.dart';
import 'package:signal_wave/signal_wave.dart';
import 'package:dart_filter/dart_filter.dart';

mixin WaveOperators<S> on WaveType<S> {
    Wave<U> map<U>(U Function(S) map) {
        return Wave<U>.custom(map(value), (EventSink<U> sink) {
            return subscribe((a) => sink.add(map(a)), sink.close);
        });
    }

    Wave<U> futureMap<U>(U initial, Future<U> Function(S) map) {
        return Wave<U>.custom(initial, (EventSink<U> sink) {
            CancelableOperation<U> currentComputation;
            bool isClosed = false;
            return subscribe((a) {
                if (currentComputation != null && !currentComputation.isCanceled)
                    currentComputation.cancel();
                currentComputation = CancelableOperation<U>.fromFuture(map(a)).then((computatedResult) async {
                    if (!isClosed)
                        sink.add(computatedResult);
                    return computatedResult;
                });
            }, () {
                isClosed = true;
                sink.close();
            });
        });
    }

    Wave<U> to<U>(U Function() convert) {
        return map((S _) => convert());
    }

    Wave<S> take(int howMany) {
        return Wave<S>.custom(value, (EventSink<S> sink) {
            int emitted = 0;
            return subscribe((val) {
                if (emitted < howMany) {
                    emitted++;
                    sink.add(val);
                }
                if (emitted == howMany)
                    sink.close();
            }, sink.close);
        });
    }

    Wave<S> skip(int howMany) {
        return Wave<S>.custom(value, (EventSink<S> sink) {
            int emitted = -1;
            return subscribe((val) {
                if (emitted < howMany)
                    emitted++;
                if (emitted >= howMany)
                    sink.add(val);
            }, sink.close);
        });
    }

    ///  a----b----c---|		(a)
    ///     x----y----z----| (x)
    ///
    ///  flatMap (mergeMap)
    ///
    ///  a--x-b--y-c--z----|
    ///  |
    ///  |- sub to a
    ///     |- sub to x
    ///
    Wave<T> flatMap<T>(Wave<T> Function(S) transform) {
        return Wave.custom(transform(value).value, (EventSink<T> sink) {
            var closedWaves = 0;
            var receivedWaves = 0;

            Disposable leftSubscription;
            bool leftIsClosed = false;

            bool leftClosed() => (leftSubscription?.isDisposed ?? false) || leftIsClosed;

            final composite = CompositeDisposable([]);

            composite.add(leftSubscription = Disposable(subscribe((value) {
                receivedWaves++;
                composite.add(
                    transform(value).subscribe(sink.add, () {
                        closedWaves++;
                        if (closedWaves == receivedWaves && leftClosed()) {
                            sink.close();
                            composite.cancel();
                        }
                    }),
                );
            }, () {
                leftIsClosed = true;
                if (closedWaves == receivedWaves)
                    sink.close();
            }).cancel));

            return composite;
        });
    }

    ///  a----b----c---|		(a)
    ///     x----y----z----| (x)
    ///
    ///  switchMap
    ///
    ///  a--x----y----z----|
    ///  |
    ///  |- sub to a
    ///     |- unsub from a and sub to x
    Wave<T> switchMap<T>(Wave<T> Function(S) transform) {
        return Wave.custom(transform(value).value, (EventSink<T> sink) {
            Disposable leftSubscription;
            Disposable rightSubscription;

            bool leftIsClosed = false,
                rightIsClosed = false;

            leftSubscription = Disposable(subscribe((value) {
                rightSubscription?.cancel();
                rightIsClosed = false;
                rightSubscription = transform(value).subscribe((data) {
                    if (!(leftSubscription?.isDisposed ?? false))
                        sink.add(data);
                }, () {
                    rightIsClosed = true;
                    if ((leftSubscription?.isDisposed ?? false) || leftIsClosed)
                        sink.close();
                });
            }, () {
                leftIsClosed = true;
                if ((rightSubscription?.isDisposed ?? false) || rightIsClosed)
                    sink.close();

            }).cancel);

            return Disposable(() {
                leftSubscription.cancel();
                rightSubscription?.cancel();
            });

        });
    }

    Wave<T> switchMapAp<T>(Wave<T Function(S)> transform) {
        return switchMap((a) => transform.map((b) => b(a)));
    }

    Wave<S> where(bool Function(S) test) {
        return Wave<S>.custom(value, (EventSink<S> sink) {
            return subscribe((a) {
                if (test(a))
                    sink.add(a);
            }, sink.close);
        });
    }

    Wave<S> criteria(Iterable<FilterCriteria<S>> criteria, {FilterCriteria<S> defaultCriteria}) {
        defaultCriteria ??= AcceptAllCriteria<S>();
        return where(AndCriteria(criteria, defaultCriteria: defaultCriteria).accepts);
    }

    Wave<S> distinct([bool Function(S oldValue, S newValue) equals]) {
        return Wave<S>.custom(value, (EventSink<S> observer) {
            S _curValue;
            bool didNotSetYet = true;
            final bool Function(S, S) eq = (S a, S b) => equals != null ? equals(a, b) : a == b;
            return subscribe((a) {
                if (didNotSetYet || !eq(_curValue, a)) {
                    didNotSetYet = false;
                    _curValue = a;
                    observer.add(a);
                }
            }, observer.close);
        });
    }

    BoolWave equals(S t) => map((a) => a == t).as(BoolWave.from);

    Wave<S> doOnAdd(void Function(S) onAdd) {
        return Wave.custom(value, (sink) {
            return subscribeEvent((event) {
                event.visit((a) => onAdd?.call(a), () {});
                sink.on(event);
            });
        });
    }
}

typedef WaveTransform<S, T> = Wave<T> Function(Wave<S> wave);
