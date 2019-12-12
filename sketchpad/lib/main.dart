import 'package:flutter/foundation.dart';
import 'package:sketchpad/colored_path_adapter.dart';
import 'package:sketchpad/drawing_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

void main() async {
  if (!kIsWeb) {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter(ColoredPathAdapter(), 35);

  runApp(DrawApp());
}

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Sketchpad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'OpenSans',
      ),
      home: FutureBuilder(
        future: Hive.openBox('sketch'),
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
              return DrawingScreen();
            }
          } else {
            return Scaffold(
              body: Center(
                child: Text('Opening Hive...'),
              ),
            );
          }
        },
      ),
    );
  }
}
