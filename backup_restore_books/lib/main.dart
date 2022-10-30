import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

const favoritesBox = 'favorite_books';
const List<String> books = [
  'Harry Potter',
  'To Kill a Mockingbird',
  'The Hunger Games',
  'The Giver',
  'Brave New World',
  'Unwind',
  'World War Z',
  'The Lord of the Rings',
  'The Hobbit',
  'Moby Dick',
  'War and Peace',
  'Crime and Punishment',
  'The Adventures of Huckleberry Finn',
  'Catch-22',
  'The Sound and the Fury',
  'The Grapes of Wrath',
  'Heart of Darkness',
];

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<String>(favoritesBox);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Box<String> favoriteBooksBox;

  @override
  void initState() {
    super.initState();
    favoriteBooksBox = Hive.box<String>(favoritesBox);
  }

  Widget getIcon(int index) {
    if (favoriteBooksBox.containsKey(index)) {
      return Icon(Icons.favorite, color: Colors.red);
    }
    return Icon(Icons.favorite_border);
  }

  void onFavoritePress(int index) {
    if (favoriteBooksBox.containsKey(index)) {
      favoriteBooksBox.delete(index);
      return;
    }
    favoriteBooksBox.put(index, books[index]);
  }

  Future<void> createBackup() async {
    if (favoriteBooksBox.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('Pick a favorite book.')),
      );
      return;
    }
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text('Creating backup...')),
    );
    Map<String, String> map = favoriteBooksBox
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value));
    String json = jsonEncode(map);
    Directory dir = await _getDirectory();
    String formattedDate = DateTime.now()
        .toString()
        .replaceAll('.', '-')
        .replaceAll(' ', '-')
        .replaceAll(':', '-');
    String path = '${dir.path}$formattedDate.hivebackup';
    File backupFile = File(path);
    await backupFile.writeAsString(json);
  }

  Future<Directory> _getDirectory() async {
    Directory directory = await getExternalStorageDirectory();
    const String pathExt = '/backups/';
    Directory newDirectory = Directory(directory.path + pathExt);
    if (await newDirectory.exists() == false) {
      return newDirectory.create(recursive: true);
    }
    return newDirectory;
  }

  Future<void> restoreBackup() async {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text('Restoring backup...')),
    );
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null) return;
    File file = File(result.files.single.path);
    favoriteBooksBox.clear();
    Map<dynamic, dynamic> map =
        jsonDecode(await file.readAsString()) as Map<dynamic, dynamic>;
    Map<int, String> newMap =
        map.map<int, String>((key, value) => MapEntry(int.parse(key), value));
    favoriteBooksBox.putAll(newMap);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favorite Books with Hive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Favorite Books w/ Hive'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.backup),
              onPressed: createBackup,
            ),
            IconButton(
              icon: Icon(Icons.restore),
              onPressed: restoreBackup,
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: favoriteBooksBox.listenable(),
          builder: (context, Box<String> box, _) {
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, listIndex) {
                return ListTile(
                  title: Text(books[listIndex]),
                  trailing: IconButton(
                    icon: getIcon(listIndex),
                    onPressed: () => onFavoritePress(listIndex),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
