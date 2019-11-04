import 'package:meta/meta.dart';

/// Base class for subscriptions that need to be cancelled.
class Disposable {
  bool _isDisposed = false;

  void Function() _dispose;

  Disposable([this._dispose]);

  bool get isDisposed => _isDisposed;

  @mustCallSuper
  void cancel() {
    if (_isDisposed) return;
    _isDisposed = true;
    this._dispose?.call();
    this._dispose = null;
  }
}

/// Collection of [Disposable]s.
class CompositeDisposable extends Disposable {
  final List<Disposable> _disposables;

  CompositeDisposable(this._disposables)
      : assert(_disposables != null),
        super(() {
          _disposables.forEach((a) => a.cancel());
        });

  void add(Disposable d) {
    if (isDisposed) {
      d.cancel();
    } else {
      _disposables.add(d);
    }
  }
}
