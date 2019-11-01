import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';
import 'package:decimal/decimal.dart';

void main() {
    group("$SortingModel", () {
        const empty = SortingModel<dynamic>.empty();

        test("empty", () {
            expect(empty.ascending, null);
            expect(empty.comparable, null);
            final List<int> a = [3, 1, 2];
            empty.doSortCollection(a);
            expect(a, [3, 1, 2]);
        });

        final SortingModel<bool> model = SortingModel(
            comparable: (bool b) => BoolComparator(value: b, map: (a) => a),
            ascending: true,
        );

        test("constructor", () {
            expect(model.ascending, true);
        });

        test("arguments not null", () {
            expect(() =>
                SortingModel(
                    comparable: (bool b) => BoolComparator(value: b, map: (dynamic a) => a as bool),
                    ascending: null,
                ),
                throwsA(const TypeMatcher<AssertionError>()),
            );
            expect(() =>
            // ignore: prefer_const_constructors
            SortingModel<dynamic>(
                comparable: null,
                ascending: true,
            ),
                throwsA(const TypeMatcher<AssertionError>()),
            );
        });

        group("$BoolComparator", () {
            test("sort bools ascending", () {
                final SortingModel<bool> model = SortingModel(
                    comparable: (bool b) => BoolComparator(value: b, map: (a) => a),
                    ascending: true,
                );

                final a = [true, false, true, false];
                model.doSortCollection(a);
                expect(a, [false, false, true, true]);
            });

            test("sort bools descending", () {
                final SortingModel<bool> model = SortingModel(
                    comparable: (bool b) => BoolComparator(value: b, map: (a) => a),
                    ascending: false,
                );

                final b = [true, false, true, false];
                model.doSortCollection(b);
                expect(b, [true, true, false, false]);
            });
        });

        group("$StringComparator", () {
            test("sort bools ascending", () {
                final SortingModel<String> model = SortingModel(
                    comparable: (String x) => StringComparator(value: x, map: (a) => a),
                    ascending: true,
                );

                final a = ["abc", "Abc", "ABC", "BCD", "bcd", "c", "a"];
                model.doSortCollection(a);
                expect(a, ['ABC', 'Abc', 'BCD', 'a', 'abc', 'bcd', 'c']);
            });

            test("sort bools descending", () {
                final SortingModel<String> model = SortingModel(
                    comparable: (String b) => StringComparator(value: b, map: (a) => a),
                    ascending: false,
                );

                final a = ["abc", "Abc", "ABC", "BCD", "bcd", "c", "a"];
                model.doSortCollection(a);
                expect(a, ['c', 'bcd', 'abc', 'a', 'BCD', 'Abc', 'ABC']);
            });
        });

        group("$DecimalNullComparator", () {
            group("sort decimals ascending ", () {
                test("${NullPriority}.smallest() (default)", () {
                    final SortingModel<Decimal> model = SortingModel(
                        comparable: (Decimal x) => DecimalNullComparator(value: x, map: (a) => a),
                        ascending: true,
                    );
                    final a = [Decimal.parse("0.124"), Decimal.parse("0.341"), Decimal.parse("1034013491.0"), null, null, Decimal.parse("123")];
                    model.doSortCollection(a);
                    expect(a, [null, null, Decimal.parse("0.124"), Decimal.parse("0.341"), Decimal.parse("123"), Decimal.parse("1034013491.0")]);
                });
                test("${NullPriority}.biggest()", () {
                    final SortingModel<Decimal> model = SortingModel(
                        comparable: (Decimal x) => DecimalNullComparator(value: x, map: (a) => a, nullPriority: const NullPriority.biggest()),
                        ascending: true,
                    );
                    final a = [Decimal.parse("0.124"), Decimal.parse("0.341"), Decimal.parse("1034013491.0"), null, null, Decimal.parse("123")];
                    model.doSortCollection(a);
                    expect(a, [Decimal.parse("0.124"), Decimal.parse("0.341"), Decimal.parse("123"), Decimal.parse("1034013491.0"), null, null]);
                });
            });

            group("sort decimals descending", () {
                test("${NullPriority}.smallest() (default)", () {
                    final SortingModel<Decimal> model = SortingModel(
                        comparable: (Decimal b) => DecimalNullComparator(value: b, map: (a) => a),
                        ascending: false,
                    );
                    final a = [Decimal.parse("0.124"), Decimal.parse("0.341"), Decimal.parse("1034013491.0"), null, null, Decimal.parse("123")];
                    model.doSortCollection(a);
                    expect(a, [Decimal.parse("1034013491.0"), Decimal.parse("123"), Decimal.parse("0.341"), Decimal.parse("0.124"), null, null]);
                });
                test("${NullPriority}.biggest()", () {
                    final SortingModel<Decimal> model = SortingModel(
                        comparable: (Decimal b) => DecimalNullComparator(value: b, map: (a) => a, nullPriority: const NullPriority.biggest()),
                        ascending: false,
                    );
                    final a = [Decimal.parse("0.124"), Decimal.parse("0.341"), Decimal.parse("1034013491.0"), null, null, Decimal.parse("123")];
                    model.doSortCollection(a);
                    expect(a, [null, null, Decimal.parse("1034013491.0"), Decimal.parse("123"), Decimal.parse("0.341"), Decimal.parse("0.124")]);
                });
            });
        });

        group("$DoubleNullComparator", () {
            group("sort doubles ascending ", () {
                test("${NullPriority}.smallest() (default)", () {
                    final SortingModel<double> model = SortingModel(
                        comparable: (double x) => DoubleNullComparator(value: x, map: (a) => a),
                        ascending: true,
                    );
                    final a = [0.124, 0.341, 1034013491.0, null, null, 123.0];
                    model.doSortCollection(a);
                    expect(a, [null, null, 0.124, 0.341, 123.0, 1034013491.0]);
                });
                test("${NullPriority}.biggest()", () {
                    final SortingModel<double> model = SortingModel(
                        comparable: (double x) => DoubleNullComparator(value: x, map: (a) => a, nullPriority: const NullPriority.biggest()),
                        ascending: true,
                    );
                    final a = [0.124, 0.341, 1034013491.0, null, null, 123.0];
                    model.doSortCollection(a);
                    expect(a, [0.124, 0.341, 123, 1034013491.0, null, null]);
                });
            });

            group("sort doubles descending", () {
                test("${NullPriority}.smallest() (default)", () {
                    final SortingModel<double> model = SortingModel(
                        comparable: (double b) => DoubleNullComparator(value: b, map: (a) => a),
                        ascending: false,
                    );
                    final a = [0.124, 0.341, 1034013491.0, null, null, 123.0];
                    model.doSortCollection(a);
                    expect(a, [1034013491.0, 123.0, 0.341, 0.124, null, null]);
                });
                test("${NullPriority}.biggest()", () {
                    final SortingModel<double> model = SortingModel(
                        comparable: (double b) => DoubleNullComparator(value: b, map: (a) => a, nullPriority: const NullPriority.biggest()),
                        ascending: false,
                    );
                    final a = [0.124, 0.341, 1034013491.0, null, null, 123.0];
                    model.doSortCollection(a);
                    expect(a, [null, null, 1034013491.0, 123, 0.341, 0.124]);
                });
            });
        });

        group("$SortableContainer", () {
            test("items not null", () {
                // ignore: prefer_const_constructors
                expect(() => SortableContainer<dynamic>(items: null), throwsA(const TypeMatcher<AssertionError>()));
            });
            test("getSorted", () {
                final list = [
                    const SortableItem(priority: 200, item: 2),
                    const SortableItem(priority: 300, item: 3),
                    const SortableItem(priority: 100, item: 1),
                ];
                expect(SortableContainer(items: list).getSorted(), [1, 2, 3]);
            });
        });

        group("$SortableItem", () {
            test("priority not null", () {
                // ignore: prefer_const_constructors
                expect(() => SortableItem(item: 0, priority: null), throwsA(const TypeMatcher<AssertionError>()));
            });
            test("item not null", () {
                // ignore: prefer_const_constructors
                expect(() => SortableItem(item: null, priority: 1), throwsA(const TypeMatcher<AssertionError>()));
            });
        });
    });
}
