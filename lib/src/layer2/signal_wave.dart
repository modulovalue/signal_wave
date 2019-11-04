import 'package:dartz/dartz.dart';
import 'package:signal_wave/signal_wave.dart';
import 'package:signal_wave/src/layer1/combine.dart';
import 'package:signal_wave/src/layer1/creation.dart';
import 'package:signal_wave/src/layer1/operators.dart';
import 'package:signal_wave/src/layer1/other.dart';

/// Waves are RxJS Observables with 2 key differences:
///
/// - They don't have an error callback
///     # Why?
///     Errors can be handled with the union: T | Error
///     Errors should
///     explicitly be handled and passed on by being wrapped in
///     an error object.
///
/// - They have a synchronously available value.
///
/// All Operators and their corresponding implementations
///
/// Those that don't make sense for waves are marked as (N/A)
///
/// Source: https://www.learnrxjs.io/operators/
/// Check out the link above to learn what each operator does.
///
/// ## Combination
///
/// combineAll                  = TODO
/// combineLatest               = [Wave.combineLatest] & 2-9
/// concat                      = TODO
/// concatAll                   = TODO
/// endWith                     = TODO
/// forkJoin                    = TODO
/// merge                       = TODO
/// mergeAll                    = TODO
/// pairwise                    = TODO
/// race                        = TODO
/// startWith                   = TODO
/// withLatestFrom              = TODO
/// zip                         = TODO
///
/// ## Conditional
///
/// defaultIfEmpty              = TODO
/// every                       = TODO
/// iif                         = TODO
/// sequenceequal               = TODO
///
/// ## Creation
///
/// ajax                        = (N/A)
/// create                      = [Wave.create] or default constructor
/// defer                       = TODO
/// empty                       = [Wave.empty]
/// from                        = [Wave.fromIterable]
/// fromEvent                   = (N/A)
/// generate                    = [Wave.generate]
/// interval                    = TODO
/// of                          = (N/A) (use [Wave.fromIterable])
/// range                       = TODO
/// throw                       = (N/A)
/// timer                       = [Wave.timer]
///
/// ## Error Handling
///
/// catch / catchError          = (N/A)
/// retry                       = (N/A)
/// retryWhen                   = (N/A)
///
/// ## Filtering
///
/// audit                       = TODO
/// auditTime                   = TODO
/// debounce                    = TODO
/// debounceTime                = TODO
/// distinctUntilChanged        = [Wave.distinct]
/// distinctUntilKeyChanged     = TODO
/// filter                      = [Wave.where]
/// find                        = TODO
/// first                       = TODO
/// ignoreElements              = TODO
/// last                        = TODO
/// sample                      = TODO
/// single                      = TODO
/// skip                        = [Wave.skip]
/// skipUntil                   = TODO
/// skipWhile                   = TODO
/// take                        = [Wave.take]
/// takeLast                    = TODO
/// takeUntil                   = TODO
/// takeWhile                   = TODO
/// throttle                    = TODO
/// throttleTime                = TODO
///
/// ## Multicasting
///
/// multicast                   = (N/A)
/// publish                     = (N/A)
/// share                       = (N/A)
/// shareReplay                 = (N/A)
///
/// ## Transformation
///
/// buffer                      = TODO
/// bufferCount                 = TODO
/// bufferTime                  = TODO
/// bufferToggle                = TODO
/// bufferWhen                  = TODO
/// concatMap                   = TODO
/// concatMapTo                 = TODO
/// expand                      = TODO
/// exhaustMap                  = TODO
/// groupBy                     = TODO
/// map                         = [Wave.map]
/// mapTo                       = TODO
/// mergeMap / flatMap          = [Wave.flatMap]
/// mergeScan                   = TODO
/// partition                   = TODO
/// pluck                       = TODO
/// reduce                      = TODO
/// scan                        = TODO
/// switchMap                   = [Wave.switchMap]
/// switchMapTo                 = TODO
/// toArray                     = TODO
/// window                      = TODO
/// windowCount                 = TODO
/// windowTime                  = TODO
/// windowToggle                = TODO
/// windowWhen                  = TODO
///
/// ## Utility
///
/// tap / do                    = (N/A)
/// delay                       = TODO
/// delayWhen                   = TODO
/// dematerialize               = (N/A)
/// finalize / finally          = (N/A)
/// let                         = (N/A)
/// repeat                      = TODO
/// timeInterval                = TODO
/// timeout                     = TODO
/// timeoutWith                 = TODO
/// toPromise                   = TODO
///
/// ----------------------------------------------
/// Furthermore, there are more operators that are
/// not included in Rx:
///
/// [Wave.equals]
///
/// ----------------------------------------------
/// Waves can also be represented by a Wave that has its
/// own set of operators.
/// Use [Wave.as] to convert a wave into a different Wave
/// representation. The following alternative Waves are already
/// available.
///
/// [BoolWave]              = [Wave]<bool>
/// [DynWave]               = [Wave]<dynamic>
/// [IntWave]               = [Wave]<int>
/// [StringWave]            = [Wave]<String>
/// [TimestampWave]         = [Wave]<int>
///
/// [CodecWave]<S, T>       = [Wave]<S>
/// [DictWave]<T>           = [Wave]<Map<String, T>>
/// [EnumWave]<T>           = [Wave]<T> where T is an enum
/// [ListWave]<T>           = [Wave]<List<T>>
/// [OptionWave]<T>         = [Wave]<Option<T>>
/// [RegistryWave]<T>       = [Wave]<Map<String, List<T>>>
///
/// This feature will be replaced by static extension methods.
/// ----------------------------------------------
///
/// Be careful when mapping signals to waves and storing the resulting wave.
/// The synchronously available value in a wave will only be up-to-date when
/// the wave is being listened to.
class Wave<S> extends WaveType<S> with WaveOtherMixin<S>, WaveOperators<S> {
  Wave(WaveType<S> wave)
      : assert(wave != null),
        this._subscribeHandler = wave.subscribeSink,
        this._value = wave.value;

  Wave.custom(
      this._value, Disposable Function(EventSink<S> sink) _subscribeHandler)
      : assert(_subscribeHandler != null),
        this._subscribeHandler = _subscribeHandler;

  factory Wave.create(WaveType<S> wave) = Wave<S>;

  factory Wave.just(S value) => justWave<S>(value);

  factory Wave.empty([S value]) => emptyWave(value);

  factory Wave.fromIterable(Iterable<S> collection) =>
      fromIterableWave(collection);

  static Wave<Option<Either<dynamic, S>>> fromStream<S>(Stream<S> stream) =>
      fromStreamWave(stream);

  factory Wave.generate(int times, S Function(int i) map) =>
      generateWave(times, map);

  factory Wave.timer(Duration duration, S Function(int) valueComputation) =>
      periodic<S>(duration, valueComputation);

  static Wave<void> updateEvery(Duration duration) =>
      periodic<void>(duration, (a) => null);

  static Wave<int> updateEverySecond() =>
      periodic<int>(const Duration(milliseconds: 1000), (a) => a);

  factory Wave.repeat(int times, S value) => repeatWave(times, value);

  static Wave<Iterable<S>> combineLatestID<S>(Iterable<Wave<S>> list) {
    return combineLatestWave(list, (Iterable<S> a) => a);
  }

  static Wave<T> combineLatest<S, T>(
      Iterable<WaveType<S>> list, T Function(Iterable<S>) map) {
    return combineLatestWave(list, map);
  }

  static Wave<R> combineLatest2<A, B, R>(
      WaveType<A> a, WaveType<B> b, R Function(A, B) map) {
    return combineLatestWave<dynamic, R>([a, b], (li) {
      return map(li.elementAt(0) as A, li.elementAt(1) as B);
    });
  }

  static Wave<R> combineLatest3<A, B, C, R>(
      WaveType<A> a, WaveType<B> b, WaveType<C> c, R Function(A, B, C) map) {
    return combineLatestWave<dynamic, R>([a, b, c], (li) {
      return map(
          li.elementAt(0) as A, li.elementAt(1) as B, li.elementAt(2) as C);
    });
  }

  static Wave<R> combineLatest4<A, B, C, D, R>(WaveType<A> a, WaveType<B> b,
      WaveType<C> c, WaveType<D> d, R Function(A, B, C, D) map) {
    return combineLatestWave<dynamic, R>([a, b, c, d], (li) {
      return map(li.elementAt(0) as A, li.elementAt(1) as B,
          li.elementAt(2) as C, li.elementAt(3) as D);
    });
  }

  static Wave<R> combineLatest5<A, B, C, D, E, R>(
      WaveType<A> a,
      WaveType<B> b,
      WaveType<C> c,
      WaveType<D> d,
      WaveType<E> e,
      R Function(A, B, C, D, E) map) {
    return combineLatestWave<dynamic, R>([a, b, c, d, e], (li) {
      return map(li.elementAt(0) as A, li.elementAt(1) as B,
          li.elementAt(2) as C, li.elementAt(3) as D, li.elementAt(4) as E);
    });
  }

  static Wave<R> combineLatest6<A, B, C, D, E, F, R>(
      WaveType<A> a,
      WaveType<B> b,
      WaveType<C> c,
      WaveType<D> d,
      WaveType<E> e,
      WaveType<F> f,
      R Function(A, B, C, D, E, F) map) {
    return combineLatestWave<dynamic, R>([a, b, c, d, e, f], (li) {
      return map(
          li.elementAt(0) as A,
          li.elementAt(1) as B,
          li.elementAt(2) as C,
          li.elementAt(3) as D,
          li.elementAt(4) as E,
          li.elementAt(5) as F);
    });
  }

  static Wave<R> combineLatest7<A, B, C, D, E, F, G, R>(
      WaveType<A> a,
      WaveType<B> b,
      WaveType<C> c,
      WaveType<D> d,
      WaveType<E> e,
      WaveType<F> f,
      WaveType<G> g,
      R Function(A, B, C, D, E, F, G) map) {
    return combineLatestWave<dynamic, R>([a, b, c, d, e, f, g], (li) {
      return map(
          li.elementAt(0) as A,
          li.elementAt(1) as B,
          li.elementAt(2) as C,
          li.elementAt(3) as D,
          li.elementAt(4) as E,
          li.elementAt(5) as F,
          li.elementAt(6) as G);
    });
  }

  static Wave<R> combineLatest8<A, B, C, D, E, F, G, H, R>(
      WaveType<A> a,
      WaveType<B> b,
      WaveType<C> c,
      WaveType<D> d,
      WaveType<E> e,
      WaveType<F> f,
      WaveType<G> g,
      WaveType<H> h,
      R Function(A, B, C, D, E, F, G, H) map) {
    return combineLatestWave<dynamic, R>([a, b, c, d, e, f, g, h], (li) {
      return map(
          li.elementAt(0) as A,
          li.elementAt(1) as B,
          li.elementAt(2) as C,
          li.elementAt(3) as D,
          li.elementAt(4) as E,
          li.elementAt(5) as F,
          li.elementAt(6) as G,
          li.elementAt(7) as H);
    });
  }

  static Wave<R> combineLatest9<A, B, C, D, E, F, G, H, I, R>(
      WaveType<A> a,
      WaveType<B> b,
      WaveType<C> c,
      WaveType<D> d,
      WaveType<E> e,
      WaveType<F> f,
      WaveType<G> g,
      WaveType<H> h,
      WaveType<I> i,
      R Function(A, B, C, D, E, F, G, H, I) map) {
    return combineLatestWave<dynamic, R>([a, b, c, d, e, f, g, h, i], (li) {
      return map(
        li.elementAt(0) as A,
        li.elementAt(1) as B,
        li.elementAt(2) as C,
        li.elementAt(3) as D,
        li.elementAt(4) as E,
        li.elementAt(5) as F,
        li.elementAt(6) as G,
        li.elementAt(7) as H,
        li.elementAt(8) as I,
      );
    });
  }

  /// Combines a list of items with a Wave for each element and returns both as a MapEntry.
  static Wave<Iterable<MapEntry<T, O>>> mapWithWave<T, O>(
      Iterable<T> data, Wave<O> Function(T t) other) {
    return Wave.combineLatestID(data.map((a) {
      return other(a).map((O b) => MapEntry(a, b));
    }));
  }

  static Wave<Iterable<T>> whereWave<T>(
      Iterable<T> data, Wave<bool> Function(T t) filter) {
    return mapWithWave<T, bool>(data, filter)
        .map((Iterable<MapEntry<T, bool>> a) {
      return a.where((a) => a.value).map((a) => a.key);
    });
  }

  static Wave<Iterable<T>> waveWaveWhere<T>(
      Wave<Iterable<T>> data, Wave<bool> Function(T t) filter) {
    return data.map((ts) => whereWave(ts, filter)).switchMap((a) => a);
  }

  Disposable Function(EventSink<S> sink) _subscribeHandler;

  @override
  S get value => _value;

  S _value;

  @override
  void onAdd(S s) => _value = s;

  T as<T>(T Function(Wave<S> o) asWhat) => asWhat(this);

  @override
  Disposable subscribeSink(EventSink<S> sink) {
    bool isDisposed = false;
    return _subscribeHandler(EventSink((event) {
      if (!isDisposed) {
        event.visit(onAdd, () {});
        event.visit(sink.add, () {
          sink.close();
          isDisposed = true;
        });
      }
    }));
  }

  TwoWave<S, Z> and<Z>(Wave<Z> z) => TwoWave(this, z);
}

Wave<T> just<T>(T t) => Wave.just(t);
