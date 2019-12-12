import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  if (!kIsWeb) {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'OpenSans',
      ),
      home: FutureBuilder(
        future: Hive.openBox('myBox'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error != null) {
              print(snapshot.error);
              return Scaffold(
                body: Center(
                  child: Text('Something went wrong :/'),
                ),
              );
            } else {
              return MyHomePage(title: 'Hive Demo Page');
            }
          } else {
            return Scaffold();
          }
        },
      ),
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
  Box _box;

  @override
  void initState() {
    _box = Hive.box('myBox');
    super.initState();
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
            if (kIsWeb)
              Text('Refresh this tab to test persistence')
            else
              Text('Restart the app to test persistence'),
            SizedBox(height: 8),
            Text('You have pushed the button this many times:'),
            WatchBoxBuilder(
              box: _box,
              builder: (context, box) {
                return Text(
                  box.get('counter', defaultValue: 0).toString(),
                  style: Theme.of(context).textTheme.display1,
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _box.put('counter', _box.get('counter', defaultValue: 0) - 1);
            },
            tooltip: 'Decrement',
            child: Icon(Icons.remove),
          ),
          SizedBox(
            width: 8,
          ),
          FloatingActionButton(
            onPressed: () {
              _box.put('counter', _box.get('counter', defaultValue: 0) + 1);
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
