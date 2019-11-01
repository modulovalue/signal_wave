import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';
import 'package:signal_wave/signal_wave.dart';

class DecimalWave extends Wave<Option<Decimal>> {

    static DecimalWave from(Wave<Option<Decimal>> a) {
        return DecimalWave(a.value, a.subscribeSink);
    }

    static DecimalWave fromStr(Wave<String> o) {
        final a = o.map(Decimal.tryParse).map(optionOf);
        return DecimalWave(a.value, a.subscribeSink);
    }

    DecimalWave(Option<Decimal> value, Disposable Function(EventSink<Option<Decimal>>) _subscribeHandler)
        : super.custom(value, _subscribeHandler);


    Wave<String> strOr(String or) => map((a) => a.map((a) => a.toString()) | or);
}
