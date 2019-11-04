import 'package:flutter/material.dart';
import 'package:signal_wave/signal_wave.dart';
import 'package:single_bloc_base/single_bloc_base.dart';

void main() => runApp(MyApp());

class CounterBloc extends HookBloc {
  final Signal<int> _counter = HookBloc.disposeSink(Signal(0));

  Wave<int> counter;

  CounterBloc() {
    counter = _counter.wave;
  }

  void addOne() {
    _counter.add(_counter.value + 1);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CounterBloc bloc;
  Disposable _counterSubscription;

  @override
  void initState() {
    super.initState();
    bloc = CounterBloc();
    bloc.counter.subscribe((_) => setState(() {}), () => print("Closed"));
  }

  @override
  void dispose() {
    _counterSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${bloc.counter.value}',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: bloc.addOne,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
