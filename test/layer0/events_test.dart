import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';

void main() {
  group("$Event", () {
    test("visit", () {
      /// Tested in subclasses
    });
  });
  group("$NextEvent", () {
    test("visit", () {
      int value = 0;
      const NextEvent<int>(10)
          .visit((a) => value = a, () => throw Exception(""));
      expect(value, 10);
    });
    test("== and hashCode", () {
      // ignore: prefer_const_constructors
      expect(NextEvent<int>(10), const NextEvent<int>(10));
      expect(const NextEvent<int>(11), isNot(const NextEvent<int>(10)));
      expect(
          const NextEvent<int>(10).hashCode, const NextEvent<int>(10).hashCode);
    });
  });
  group("$CloseEvent", () {
    test("visit", () {
      int value = 0;
      const CloseEvent<int>()
          .visit((a) => throw Exception(""), () => value = 10);
      expect(value, 10);
    });
    test("== and hashCode", () {
      // ignore: prefer_const_constructors
      expect(CloseEvent<int>(), const CloseEvent<int>());
      expect(
          const CloseEvent<int>().hashCode, const CloseEvent<int>().hashCode);
    });
  });
  group("$KeyedEvent", () {
    group("visits the passed event", () {
      test("CloseEvent", () {
        final List<int> list = [];
        const KeyedEvent("a", CloseEvent<int>())
            .visit((_) => fail, () => list.add(1));
        expect(list, [1]);
      });
      test("NextEvent", () {
        final List<int> list = [];
        const KeyedEvent("a", NextEvent<int>(3)).visit(list.add, () => fail);
        expect(list, [3]);
      });
    });
    test("== & != & hashCode", () {
      expect(
        // ignore: prefer_const_constructors
        KeyedEvent("a", CloseEvent<int>()),
        // ignore: prefer_const_constructors
        KeyedEvent("a", CloseEvent<int>()),
      );
      expect(
        // ignore: prefer_const_constructors
        KeyedEvent("a", CloseEvent<int>()).hashCode,
        // ignore: prefer_const_constructors
        KeyedEvent("a", CloseEvent<int>()).hashCode,
      );
      expect(
        // ignore: prefer_const_constructors
        KeyedEvent("a", CloseEvent<int>()),
        // ignore: prefer_const_constructors
        isNot(KeyedEvent("b", CloseEvent<int>())),
      );
      expect(
        // ignore: prefer_const_constructors
        KeyedEvent("a", CloseEvent<int>()),
        // ignore: prefer_const_constructors
        isNot(KeyedEvent("a", NextEvent<int>(2))),
      );
    });
  });
}
