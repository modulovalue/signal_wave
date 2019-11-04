import 'package:signal_wave/signal_wave.dart';
import 'package:test/test.dart';

void main() {
  group("$SignalValue", () {
    /// Nothing to test
  });
  group("$WaveType", () {});
  group("$EventSink", () {
    /// Nothing to test
  });
  group("_AnonEventSink", () {
    test("on", () {
      Event<int> event;
      const Event<int> a = NextEvent(1);
      const Event<int> b = CloseEvent();
      EventSink<int>((e) => event = e).on(a);
      expect(event, a);
      EventSink<int>((e) => event = e).on(b);
      expect(event, b);
    });
    test("add & close", () {
      Event<int> event;
      const Event<int> a = NextEvent(1);
      EventSink<int>((e) => event = e).add(1);
      expect(event, a);
      EventSink<int>((e) => event = e).close();
      expect(event, const CloseEvent<int>());
    });
  });
}
