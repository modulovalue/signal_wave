import 'package:signal_wave/signal_wave.dart';

class TwoWave<A, B> {
  final Wave<A> a;
  final Wave<B> b;

  TwoWave(this.a, this.b);

  ThreeWave<A, B, Z> and<Z>(Wave<Z> other) => ThreeWave(a, b, other);

  Wave<Z> latest<Z>(Z Function(A, B) map) => Wave.combineLatest2(a, b, map);
}

class ThreeWave<A, B, C> {
  final Wave<A> a;
  final Wave<B> b;
  final Wave<C> c;

  const ThreeWave(this.a, this.b, this.c);

  FourWave<A, B, C, Z> and<Z>(Wave<Z> other) => FourWave(a, b, c, other);

  Wave<Z> latest<Z>(Z Function(A, B, C) map) =>
      Wave.combineLatest3(a, b, c, map);
}

class FourWave<A, B, C, D> {
  final Wave<A> a;
  final Wave<B> b;
  final Wave<C> c;
  final Wave<D> d;

  const FourWave(this.a, this.b, this.c, this.d);

  FiveWave<A, B, C, D, Z> and<Z>(Wave<Z> other) => FiveWave(a, b, c, d, other);

  Wave<Z> latest<Z>(Z Function(A, B, C, D) map) =>
      Wave.combineLatest4(a, b, c, d, map);
}

class FiveWave<A, B, C, D, E> {
  final Wave<A> a;
  final Wave<B> b;
  final Wave<C> c;
  final Wave<D> d;
  final Wave<E> e;

  const FiveWave(this.a, this.b, this.c, this.d, this.e);

  SixWave<A, B, C, D, E, Z> and<Z>(Wave<Z> other) =>
      SixWave(a, b, c, d, e, other);

  Wave<Z> latest<Z>(Z Function(A, B, C, D, E) map) =>
      Wave.combineLatest5(a, b, c, d, e, map);
}

class SixWave<A, B, C, D, E, F> {
  final Wave<A> a;
  final Wave<B> b;
  final Wave<C> c;
  final Wave<D> d;
  final Wave<E> e;
  final Wave<F> f;

  const SixWave(this.a, this.b, this.c, this.d, this.e, this.f);

  SevenWave<A, B, C, D, E, F, Z> and<Z>(Wave<Z> other) =>
      SevenWave(a, b, c, d, e, f, other);

  Wave<Z> latest<Z>(Z Function(A, B, C, D, E, F) map) =>
      Wave.combineLatest6(a, b, c, d, e, f, map);
}

class SevenWave<A, B, C, D, E, F, G> {
  final Wave<A> a;
  final Wave<B> b;
  final Wave<C> c;
  final Wave<D> d;
  final Wave<E> e;
  final Wave<F> f;
  final Wave<G> g;

  const SevenWave(this.a, this.b, this.c, this.d, this.e, this.f, this.g);

  EightWave<A, B, C, D, E, F, G, Z> and<Z>(Wave<Z> other) =>
      EightWave(a, b, c, d, e, f, g, other);

  Wave<Z> latest<Z>(Z Function(A, B, C, D, E, F, G) map) =>
      Wave.combineLatest7(a, b, c, d, e, f, g, map);
}

class EightWave<A, B, C, D, E, F, G, H> {
  final Wave<A> a;
  final Wave<B> b;
  final Wave<C> c;
  final Wave<D> d;
  final Wave<E> e;
  final Wave<F> f;
  final Wave<G> g;
  final Wave<H> h;

  const EightWave(
      this.a, this.b, this.c, this.d, this.e, this.f, this.g, this.h);

  NineWave<A, B, C, D, E, F, G, H, Z> and<Z>(Wave<Z> other) =>
      NineWave(a, b, c, d, e, f, g, h, other);

  Wave<Z> latest<Z>(Z Function(A, B, C, D, E, F, G, H) map) =>
      Wave.combineLatest8(a, b, c, d, e, f, g, h, map);
}

class NineWave<A, B, C, D, E, F, G, H, I> {
  final Wave<A> a;
  final Wave<B> b;
  final Wave<C> c;
  final Wave<D> d;
  final Wave<E> e;
  final Wave<F> f;
  final Wave<G> g;
  final Wave<H> h;
  final Wave<I> i;

  const NineWave(
      this.a, this.b, this.c, this.d, this.e, this.f, this.g, this.h, this.i);

  Wave<Z> latest<Z>(Z Function(A, B, C, D, E, F, G, H, I) map) =>
      Wave.combineLatest9(a, b, c, d, e, f, g, h, i, map);
}
