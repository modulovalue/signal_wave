import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:signal_wave/signal_wave.dart';

class ListWave<T> extends Wave<List<T>> {
    static ListWave<T> from<T>(Wave<Iterable<T>> o) {
        return ListWave(o.map((a) => a.toList()));
    }

    ListWave(WaveType<List<T>> o) : super(o);

    BoolWave contains(T t) => map((a) => a.contains(t)).as(BoolWave.from);

    IntWave length() => map((a) => a.length).as(IntWave.from);

    BoolWave isEmpty() => map((a) => a.isEmpty).as(BoolWave.from);

    ListWave<T> filter(bool Function(T) test) => map((a) => a.where(test)).as(ListWave.from);

    ListWave<T> prioritySort(SortableItem<T> Function(T) wrap) {
        return map((a) => a.map(wrap))
            .map((a) => SortableContainer<T>(items: List.from(a)).getSorted())
            .as(ListWave.from);
    }

    ListWave<T> comparableSort(Comparable<T> Function(T) comparable, bool ascending) {
        return map((a) {
            final list = List.of(a);
            SortingModel<T>(comparable: comparable, ascending: ascending).doSortCollection(list);
            return list;
        })
            .as(ListWave.from);
    }

    ListWave<T> waveWhere(Wave<bool> Function(T) where) {
        return Wave.waveWaveWhere(this, where).as(ListWave.from);
    }
}

/// Stores information about how to sort a set of data.
///
/// [S] is the type of data the collection contains.
class SortingModel<S> {

    final Comparable<S> Function(S) comparable;

    final bool ascending;

    const SortingModel({
        @required this.comparable,
        @required this.ascending,
    })
        : assert(comparable != null),
            assert(ascending != null);

    const SortingModel.empty()
        : comparable = null,
            ascending = null;

    void doSortCollection(List<S> collection) => collection.sort(sortFunction);

    Iterable<S> sort(Iterable<S> collection) {
        if (comparable == null)
            return collection;
        else
            return collection.toList()
                ..sort(sortFunction);
    }

    int sortFunction(S a, S b) {
        if (comparable == null)
            return 0;

        if (!ascending)
            return comparable(b).compareTo(a);

        return comparable(a).compareTo(b);
    }
}

/// Sorted with [SortingModel]
///  - Ascending order puts false values in the front.
///  - Descending order puts true values in the front.
class BoolComparator<T> implements Comparable<T> {

    final T value;

    final bool Function(T) map;

    const BoolComparator({
        @required this.value,
        @required this.map,
    });

    @override
    int compareTo(T other) {
        final aFav = map(value);
        final bFav = map(other);

        if (aFav == false && bFav == true) {
            return -1;
        } else if (aFav == true && bFav == false) {
            return 1;
        }

        return 0;
    }
}

/// Uses String's compareTo to order strings.
///
/// Sorted with [SortingModel]
/// input ["abc", "Abc", "ABC", "BCD", "bcd", "c", "a"]
///  - Descending: ['ABC', 'Abc', 'BCD', 'a', 'abc', 'bcd', 'c']
///  - Ascending: ['c', 'bcd', 'abc', 'a', 'BCD', 'Abc', 'ABC']
class StringComparator<T> implements Comparable<T> {

    final T value;

    final String Function(T) map;

    const StringComparator({
        @required this.value,
        @required this.map,
    });

    @override
    int compareTo(T other) {
        final aFav = map(other);
        final bFav = map(value);

        return bFav.compareTo(aFav);
    }
}

class DoubleNullComparator<T> implements Comparable<T> {

    final T value;

    final double Function(T) map;

    final NullPriority nullPriority;

    const DoubleNullComparator({
        @required this.value,
        @required this.map,
        this.nullPriority = const NullPriority.smallest(),
    });

    @override
    int compareTo(T other) => _InheritedComparator<double>(map(value), nullPriority).compareTo(map(other));
}

class DecimalNullComparator<T> implements Comparable<T> {

    final T value;

    final Decimal Function(T) map;

    final NullPriority nullPriority;

    const DecimalNullComparator({
        @required this.value,
        @required this.map,
        this.nullPriority = const NullPriority.smallest(),
    });

    @override
    int compareTo(T other) => _InheritedComparator(map(value), nullPriority).compareTo(map(other));
}

/// Uses the compareTo of the type if it already has one.
class _InheritedComparator<T extends Comparable<dynamic>> implements Comparable<T> {

    final NullPriority nullPriority;

    final T value;

    const _InheritedComparator(this.value, this.nullPriority);

    @override
    int compareTo(T other) {
        final a = value;
        final b = other;

        if (a == null && b == null) {
            return 0;
        } else if (a == null) {
            return nullPriority._leftNull;
        } else if (b == null) {
            return nullPriority._rightNull;
        }

        return a.compareTo(b);
    }
}

/// Tells where nulls should be put when a list is sorted.
class NullPriority {

    final int _leftNull;

    final int _rightNull;

    const NullPriority.biggest()
        : _leftNull = 1,
            _rightNull = -1;

    const NullPriority.smallest()
        : _leftNull = -1,
            _rightNull = 1;
}

/// Sorts a list of items.
///
/// Useful where a list of widgets is needed and widgets
/// should be inserted at a later stage at a specific position.
class SortableContainer<T> {

    final List<SortableItem<T>> items;

    const SortableContainer({@required this.items}) : assert(items != null);

    List<T> getSorted() => (items..sort((a, b) => a.priority.compareTo(b.priority))).map((a) => a.item).toList();
}

/// An item of a [SortableContainer].
class SortableItem<T> {

    final int priority;

    final T item;

    const SortableItem({
        @required this.priority,
        @required this.item,
    })
        : assert(priority != null),
            assert(item != null);
}