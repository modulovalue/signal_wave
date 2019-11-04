import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';

void main() {
  group("$Disposable", () {
    test("default", () {
      bool called = false;
      final d = Disposable(() => called = true);
      expect(called, false);
      expect(d.isDisposed, false);
      d.cancel();
      expect(called, true);
      expect(d.isDisposed, true);
    });
  });
  group("$CompositeDisposable", () {
    test("multiple disposables are disposed", () {
      final List<int> disposed = [];

      final CompositeDisposable disposable = CompositeDisposable([]);
      disposable.add(Disposable(() => disposed.add(1)));
      disposable.add(Disposable(() => disposed.add(2)));
      disposable.cancel();

      expect(disposed, [1, 2]);
    });

    test("called cancel multiple times does nothing", () {
      int called = 0;
      final CompositeDisposable disposable = CompositeDisposable([]);
      disposable.add(Disposable(() => called++));
      disposable.cancel();
      expect(called, 1);
      disposable.cancel();
      expect(called, 1);
    });
    test("passed disposables to a closed disposable are closed immediately",
        () {
      final CompositeDisposable disposable = CompositeDisposable([]);
      disposable.cancel();
      int called = 0;
      disposable.add(Disposable(() => called++));
      expect(called, 1);
    });
  });
}
