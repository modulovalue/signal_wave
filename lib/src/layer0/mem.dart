R Function() mem0<R>(R Function() f) {
    R value;
    return () => value ??= f();
}

R Function(A) mem1<R, A>(R Function(A arg) f) {
    final Map<A, R> cache = {};
    return (A arg) {
        if (!cache.containsKey(arg)) {
            final result = f(arg);
            cache[arg] = result;
        }
        return cache[arg];
    };
}

R Function(A, B) mem2<R, A, B>(R Function(A arg1, B arg2) f) {
    final Map<A, Map<B, R>> cache = {};

    return (A arg1, B arg2) {
        if (!cache.containsKey(arg1) || !cache[arg1].containsKey(arg2)) {
            final result = f(arg1, arg2);
            cache.putIfAbsent(arg1, () => {});
            cache[arg1][arg2] = result;
        }

        return cache[arg1][arg2];
    };
}